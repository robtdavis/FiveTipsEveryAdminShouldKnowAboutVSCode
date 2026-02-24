# Stale Opportunity Nudge Demo - Hidden Qualification Rule

## Overview

This Apex demo demonstrates a realistic scenario where a batch job appears to users like "it didn't run," when in reality the records simply **did not qualify** due to a hidden business rule.

## The Hidden Rule

**The Opportunity Owner must be ACTIVE (Owner.IsActive = true)**

This rule is buried among several other legitimate qualification checks in the `H2_StaleOpportunityNudgeService.qualifiesForNudge()` method.

## Why This Matters

### Realistic Business Scenario

Users often report: *"The nightly batch job didn't run! My stale opportunities weren't updated!"*

But when an admin investigates:
- ✅ The batch job **did** run successfully
- ✅ The batch logged "X records processed"
- ✅ No errors were thrown
- ❌ The user's opportunities were **skipped** because their owner is inactive

### Why Users Miss This

1. **Multiple Qualification Rules**: The inactive owner check is one of 5 qualification rules:
   - Must be an open opportunity (not closed)
   - Must be stale (no activity in 14+ days)
   - Must not be marked "Do Not Nudge"
   - Must not have been recently nudged (within 7 days)
   - **Must have an active owner** ⬅️ THE HIDDEN ONE

2. **Legitimate Business Logic**: It makes sense that inactive users shouldn't receive notifications - they won't see emails or Salesforce notifications anyway.

3. **Easy to Overlook**: When scanning the code quickly, users focus on:
   - The stale date calculation
   - The Do Not Nudge flag
   - The recently nudged check
   
   They often skip over the owner active check because it's grouped with other "obvious" checks.

## Demo Architecture

### Files Created

1. **H2_StaleOpportunityNudgeConfig.cls**
   - Configuration constants (stale days, batch size, etc.)
   - Centralizes business rules
   - Query definition

2. **H2_StaleOpportunityNudgeService.cls**
   - Business logic separated from batch execution
   - `qualifiesForNudge()` method with 5 qualification rules
   - `hasActiveOwner()` private method - THE HIDDEN CHECK
   - Processing logic for qualified opportunities

3. **H2_StaleOpportunityNudgeBatch.cls**
   - Database.Batchable + Database.Stateful
   - Tracks metrics across batch iterations
   - Delegates to service layer
   - Logs detailed summary in finish()

4. **H2_StaleOpportunityNudgeScheduler.cls**
   - Schedulable wrapper
   - Can be scheduled for nightly execution

5. **H2_StaleOpportunityNudgeTest.cls**
   - Comprehensive test coverage
   - Creates realistic test scenarios including:
     - ✅ Stale opp with **active** owner (SHOULD process)
     - ❌ Stale opp with **inactive** owner (SKIPPED - hidden case)
     - Other edge cases (recent activity, do not nudge, etc.)

## How to Demonstrate

### Step 1: Deploy to Your Org

Deploy all classes to a scratch org or developer org:

```bash
sf project deploy start --manifest manifest/package.xml --target-org YourOrgAlias
```

### Step 2: Create Custom Field (if not exists)

Create these custom fields on Opportunity:
- `Last_Nudged_On__c` (Date)
- `Do_Not_Nudge__c` (Checkbox)

### Step 3: Set Up Test Data

In Developer Console or VS Code, run:

```apex
// Create active and inactive users
Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

User activeUser = new User(
    FirstName = 'Active',
    LastName = 'Owner',
    Email = 'active@demo.test',
    Username = 'active.demo.' + System.currentTimeMillis() + '@test.example.com',
    Alias = 'actdemo',
    TimeZoneSidKey = 'America/Los_Angeles',
    LocaleSidKey = 'en_US',
    EmailEncodingKey = 'UTF-8',
    ProfileId = p.Id,
    LanguageLocaleKey = 'en_US',
    IsActive = true
);

User inactiveUser = new User(
    FirstName = 'Inactive',
    LastName = 'Owner',
    Email = 'inactive@demo.test',
    Username = 'inactive.demo.' + System.currentTimeMillis() + '@test.example.com',
    Alias = 'inactdmo',
    TimeZoneSidKey = 'America/Los_Angeles',
    LocaleSidKey = 'en_US',
    EmailEncodingKey = 'UTF-8',
    ProfileId = p.Id,
    LanguageLocaleKey = 'en_US',
    IsActive = false
);

insert new List<User>{ activeUser, inactiveUser };

// Create test account
Account acc = new Account(Name = 'Demo Account');
insert acc;

// Create stale opportunities
List<Opportunity> opps = new List<Opportunity>();

opps.add(new Opportunity(
    Name = 'Stale Opp - Active Owner',
    AccountId = acc.Id,
    StageName = 'Prospecting',
    CloseDate = System.today().addDays(30),
    Amount = 10000,
    OwnerId = activeUser.Id,
    LastActivityDate = System.today().addDays(-20)
));

opps.add(new Opportunity(
    Name = 'Stale Opp - Inactive Owner',
    AccountId = acc.Id,
    StageName = 'Prospecting',
    CloseDate = System.today().addDays(30),
    Amount = 15000,
    OwnerId = inactiveUser.Id,
    LastActivityDate = System.today().addDays(-20)
));

insert opps;
```

### Step 4: Run the Batch

```apex
Database.executeBatch(new H2_StaleOpportunityNudgeBatch(), 200);
```

### Step 5: Show the "Problem" to Your Audience

**Before showing the results**, build the narrative:

1. "We have two stale opportunities, both 20 days old with no activity"
2. "Both are in Prospecting stage, both are open"
3. "Neither has been nudged before"
4. "Let's run the batch job..."

### Step 6: Reveal the Results

Query the opportunities:

```apex
List<Opportunity> results = [
    SELECT Name, Last_Nudged_On__c, Owner.Name, Owner.IsActive
    FROM Opportunity
    WHERE Name LIKE 'Stale Opp%'
];

for (Opportunity opp : results) {
    System.debug(opp.Name + ': ' + 
                 'Nudged=' + opp.Last_Nudged_On__c + ', ' +
                 'Owner=' + opp.Owner.Name + ', ' +
                 'OwnerActive=' + opp.Owner.IsActive);
}
```

**Expected Output:**
```
Stale Opp - Active Owner: Nudged=2026-02-24, Owner=Active Owner, OwnerActive=true
Stale Opp - Inactive Owner: Nudged=null, Owner=Inactive Owner, OwnerActive=false
```

**THE KEY POINT**: Only ONE opportunity got nudged, even though BOTH appeared to qualify!

### Step 7: The Reveal

Now show the code and walk through `H2_StaleOpportunityNudgeService.qualifiesForNudge()`:

1. Point out the 5 qualification checks
2. Show that all checks passed for both opportunities...
3. **EXCEPT** the `hasActiveOwner()` check
4. Show the `hasActiveOwner()` method:

```apex
private Boolean hasActiveOwner(Opportunity opp) {
    return opp.Owner.IsActive == true;
}
```

**The AHA Moment**: "The batch ran successfully. The job didn't fail. The record just didn't qualify because the owner is inactive!"

## Conference Talk Points

### Why This Pattern Matters

1. **Users focus on dates and flags**: They check LastActivityDate, Do_Not_Nudge__c, etc.
2. **They miss relationship fields**: Owner.IsActive is a lookup field property
3. **The batch appears broken**: "It should have processed my record!"
4. **The real issue**: The record didn't qualify

### Prevention Strategies

1. **Better Logging**: Log WHY records were skipped
   ```apex
   if (!hasActiveOwner(opp)) {
       System.debug('Skipped ' + opp.Name + ': Owner is inactive');
       return false;
   }
   ```

2. **Summary Reports**: Include skip reasons in the finish() summary
   ```apex
   summary += 'Skipped due to inactive owner: ' + inactiveOwnerCount + '\n';
   ```

3. **Documentation**: Document ALL qualification rules clearly
4. **Custom Objects**: Log batch execution details to a custom object for auditing

### VS Code Debug Techniques

This is where you can demonstrate VS Code features:

1. **Apex Log Analysis**: Show how to filter logs for specific opportunities
2. **SOQL Queries**: Use Command Palette to run SOQL and find non-qualifying records
3. **Apex Replay Debugger**: Step through the qualification logic
4. **Code Search**: Use "Find in Files" to search for all qualification checks

## Custom Fields Required

For this demo to work, create these custom fields on Opportunity:

| Field Name | API Name | Type | Description |
|------------|----------|------|-------------|
| Last Nudged On | `Last_Nudged_On__c` | Date | Timestamp when opportunity was last nudged |
| Do Not Nudge | `Do_Not_Nudge__c` | Checkbox | Opt-out flag for specific opportunities |

## Test Coverage

Run the test class to verify everything works:

```bash
sf apex run test --test-level RunSpecifiedTests --tests H2_StaleOpportunityNudgeTest --target-org YourOrgAlias
```

Expected results:
- All tests pass ✅
- Code coverage > 75% ✅
- Demonstrates the hidden behavior ✅

## Summary

This demo perfectly illustrates how legitimate business logic can create user confusion when:
- The rule is valid (inactive owners shouldn't get notifications)
- The rule is buried among other checks
- The batch "succeeds" but records are skipped
- Users expect different behavior

It's a powerful teaching moment about:
- Clear documentation
- Comprehensive logging
- Understanding all qualification rules
- Reading code carefully before claiming "it's broken"
