/**
 * Test class for the Stale Opportunity Nudge batch process.
 * 
 * This test class demonstrates realistic scenarios including the "hidden" behavior
 * where opportunities owned by inactive users don't get processed.
 */
@IsTest
private class H2_StaleOpportunityNudgeTest {
    
    /**
     * Creates test data including users, accounts, and opportunities
     */
    @TestSetup
    static void setupTestData() {
        // Create test users - one active, one inactive
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User activeUser = new User(
            FirstName = 'Active',
            LastName = 'User',
            Email = 'active.user@test.example.com',
            Username = 'active.user.' + System.currentTimeMillis() + '@test.example.com',
            Alias = 'actuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        
        User inactiveUser = new User(
            FirstName = 'Inactive',
            LastName = 'User',
            Email = 'inactive.user@test.example.com',
            Username = 'inactive.user.' + System.currentTimeMillis() + '@test.example.com',
            Alias = 'inacuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = false
        );
        
        insert new List<User>{ activeUser, inactiveUser };
        
        // Create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create opportunities with various scenarios
        List<Opportunity> opportunities = new List<Opportunity>();
        
        // Scenario 1: Stale opportunity, active owner - SHOULD BE PROCESSED
        opportunities.add(new Opportunity(
            Name = 'Stale Opp - Active Owner',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Amount = 10000,
            OwnerId = activeUser.Id,
            Last_Nudged_On__c = null,
            Do_Not_Nudge__c = false
        ));
        
        // Scenario 2: Stale opportunity, INACTIVE owner - SHOULD BE SKIPPED (THE HIDDEN CASE)
        opportunities.add(new Opportunity(
            Name = 'Stale Opp - Inactive Owner',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Amount = 15000,
            OwnerId = inactiveUser.Id,
            Last_Nudged_On__c = null,
            Do_Not_Nudge__c = false
        ));
        
        // Scenario 3: Not stale, active owner - SHOULD BE SKIPPED
        opportunities.add(new Opportunity(
            Name = 'Recent Activity - Active Owner',
            AccountId = testAccount.Id,
            StageName = 'Qualification',
            CloseDate = System.today().addDays(45),
            Amount = 25000,
            OwnerId = activeUser.Id,
            Last_Nudged_On__c = null,
            Do_Not_Nudge__c = false
        ));
        
        // Scenario 4: Stale but marked "Do Not Nudge", active owner - SHOULD BE SKIPPED
        opportunities.add(new Opportunity(
            Name = 'Stale - Do Not Nudge',
            AccountId = testAccount.Id,
            StageName = 'Negotiation',
            CloseDate = System.today().addDays(15),
            Amount = 50000,
            OwnerId = activeUser.Id,
            Last_Nudged_On__c = null,
            Do_Not_Nudge__c = true // Opted out
        ));
        
        // Scenario 5: Stale but recently nudged, active owner - SHOULD BE SKIPPED
        opportunities.add(new Opportunity(
            Name = 'Stale - Recently Nudged',
            AccountId = testAccount.Id,
            StageName = 'Proposal',
            CloseDate = System.today().addDays(20),
            Amount = 35000,
            OwnerId = activeUser.Id,
            Last_Nudged_On__c = System.today().addDays(-3), // Nudged 3 days ago
            Do_Not_Nudge__c = false
        ));
        
        // Scenario 6: Closed Won - SHOULD BE SKIPPED (filtered by query)
        opportunities.add(new Opportunity(
            Name = 'Closed Won Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Closed Won',
            CloseDate = System.today().addDays(-10),
            Amount = 100000,
            OwnerId = activeUser.Id,
            Last_Nudged_On__c = null,
            Do_Not_Nudge__c = false
        ));
        
        insert opportunities;
        
        // Create Tasks to set LastActivityDate for stale opportunities
        // Note: LastActivityDate is read-only and can only be set via Task/Event creation
        List<Task> tasks = new List<Task>();
        
        // Create old task for Stale Opp - Active Owner (20 days ago)
        tasks.add(new Task(
            WhatId = opportunities[0].Id,
            Subject = 'Old Task',
            Status = 'Completed',
            ActivityDate = System.today().addDays(-20)
        ));
        
        // Create old task for Stale Opp - Inactive Owner (20 days ago)
        tasks.add(new Task(
            WhatId = opportunities[1].Id,
            Subject = 'Old Task',
            Status = 'Completed',
            ActivityDate = System.today().addDays(-20)
        ));
        
        // Create recent task for Recent Activity opp (5 days ago)
        tasks.add(new Task(
            WhatId = opportunities[2].Id,
            Subject = 'Recent Task',
            Status = 'Completed',
            ActivityDate = System.today().addDays(-5)
        ));
        
        // Create old task for Do Not Nudge opp (25 days ago)
        tasks.add(new Task(
            WhatId = opportunities[3].Id,
            Subject = 'Old Task',
            Status = 'Completed',
            ActivityDate = System.today().addDays(-25)
        ));
        
        // Create old task for Recently Nudged opp (18 days ago)
        tasks.add(new Task(
            WhatId = opportunities[4].Id,
            Subject = 'Old Task',
            Status = 'Completed',
            ActivityDate = System.today().addDays(-18)
        ));
        
        // Create old task for Closed Won opp (30 days ago)
        tasks.add(new Task(
            WhatId = opportunities[5].Id,
            Subject = 'Old Task',
            Status = 'Completed',
            ActivityDate = System.today().addDays(-30)
        ));
        
        insert tasks;
    }
    
    /**
     * Tests the batch job execution
     */
    @IsTest
    static void testBatchExecution() {
        Test.startTest();
        
        // Execute the batch
        H2_StaleOpportunityNudgeBatch batch = new H2_StaleOpportunityNudgeBatch();
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Query all opportunities to check what was processed
        List<Opportunity> allOpps = [
            SELECT Id, Name, Last_Nudged_On__c, Owner.IsActive
            FROM Opportunity
            ORDER BY Name
        ];
        
        // Verify results
        for (Opportunity opp : allOpps) {
            if (opp.Name == 'Stale Opp - Active Owner') {
                // This one should have been processed
                System.assertNotEquals(null, opp.Last_Nudged_On__c, 
                    'Stale opportunity with active owner should have been nudged');
                System.assertEquals(System.today(), opp.Last_Nudged_On__c,
                    'Nudge date should be today');
            }
            else if (opp.Name == 'Stale Opp - Inactive Owner') {
                // THE HIDDEN CASE: This looks like it should be processed,
                // but won't be because the owner is inactive
                System.assertEquals(null, opp.Last_Nudged_On__c,
                    'Opportunity with inactive owner should NOT have been nudged - ' +
                    'this is the hidden qualification rule!');
            }
            else {
                // All other scenarios should not have been processed
                System.assertEquals(null, opp.Last_Nudged_On__c,
                    opp.Name + ' should not have been nudged');
            }
        }
        
        // Verify only 1 opportunity was actually processed
        Integer nudgedCount = [
            SELECT COUNT() 
            FROM Opportunity 
            WHERE Last_Nudged_On__c = TODAY
        ];
        System.assertEquals(1, nudgedCount, 
            'Only one opportunity should have been nudged');
    }
    
    /**
     * Tests the scheduler
     */
    @IsTest
    static void testScheduler() {
        Test.startTest();
        
        // Schedule the job
        String cronExpression = '0 0 2 * * ?'; // 2 AM daily
        String jobId = System.schedule(
            'Test Stale Opportunity Nudge',
            cronExpression,
            new H2_StaleOpportunityNudgeScheduler()
        );
        
        // Verify the job was scheduled
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        
        System.assertEquals(cronExpression, ct.CronExpression,
            'Cron expression should match');
        System.assertEquals(0, ct.TimesTriggered,
            'Job should not have been triggered yet');
        
        Test.stopTest();
    }
    
    /**
     * Tests the service layer directly
     */
    @IsTest
    static void testServiceQualificationLogic() {
        // Get test opportunities
        List<Opportunity> opps = [
            SELECT Id, Name, IsClosed, StageName, Amount,
                   Owner.Id, Owner.Name, Owner.IsActive, Owner.Email,
                   LastActivityDate, Last_Nudged_On__c, Do_Not_Nudge__c
            FROM Opportunity
            WHERE Name IN ('Stale Opp - Active Owner', 'Stale Opp - Inactive Owner')
        ];
        
        H2_StaleOpportunityNudgeService service = new H2_StaleOpportunityNudgeService();
        
        for (Opportunity opp : opps) {
            Boolean qualifies = service.qualifiesForNudge(opp);
            
            if (opp.Name == 'Stale Opp - Active Owner') {
                System.assertEquals(true, qualifies,
                    'Stale opportunity with active owner should qualify');
            }
            else if (opp.Name == 'Stale Opp - Inactive Owner') {
                System.assertEquals(false, qualifies,
                    'Opportunity with inactive owner should NOT qualify - ' +
                    'this demonstrates the hidden rule');
            }
        }
    }
    
    /**
     * Tests processing with empty dataset
     */
    @IsTest
    static void testBatchWithNoQualifyingRecords() {
        // Delete all test opportunities
        delete [SELECT Id FROM Opportunity];
        
        Test.startTest();
        
        H2_StaleOpportunityNudgeBatch batch = new H2_StaleOpportunityNudgeBatch();
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        // Should complete successfully with no errors
        Integer oppCount = [SELECT COUNT() FROM Opportunity];
        System.assertEquals(0, oppCount, 'No opportunities should exist');
    }
}
