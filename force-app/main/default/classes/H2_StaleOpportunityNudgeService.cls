/**
 * Service class containing the business logic for the Stale Opportunity Nudge process.
 * Separates qualification rules and processing logic from batch execution.
 */
public with sharing class H2_StaleOpportunityNudgeService {
    
    /**
     * Result wrapper for processing operations
     */
    public class ProcessingResult {
        public Integer qualified { get; set; }
        public Integer processed { get; set; }
        public Integer skipped { get; set; }
        
        public ProcessingResult() {
            this.qualified = 0;
            this.processed = 0;
            this.skipped = 0;
        }
    }
    
    /**
     * Determines if an Opportunity qualifies for nudging.
     * 
     * Business Rules:
     * 1. Must be an open opportunity (not closed)
     * 2. Must be stale (no recent activity)
     * 3. Must not be marked as "Do Not Nudge"
     * 4. Must not have been recently nudged
     * 5. Owner must be active to receive notifications
     * 
     * @param opp The Opportunity record with Owner relationship
     * @return true if the opportunity qualifies for nudging
     */
    public Boolean qualifiesForNudge(Opportunity opp) {
        // Rule 1: Must be open (query already filters closed, but double-check)
        if (!isOpenOpportunity(opp)) {
            return false;
        }
        
        // Rule 2: Must be stale (no activity in configured timeframe)
        if (!isStaleOpportunity(opp)) {
            return false;
        }
        
        // Rule 3: Respect the Do Not Nudge flag
        if (isMarkedDoNotNudge(opp)) {
            return false;
        }
        
        // Rule 4: Don't spam - check if recently nudged
        if (wasRecentlyNudged(opp)) {
            return false;
        }
        
        // Rule 5: Only nudge if owner can receive notifications
        // (Inactive users won't receive emails or see notifications)
        if (!hasActiveOwner(opp)) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Processes a list of qualified opportunities.
     * Updates Last_Nudged_On__c field and prepares for email notification.
     * 
     * @param opportunities List of opportunities that passed qualification
     * @return ProcessingResult with counts of processed records
     */
    public ProcessingResult processOpportunities(List<Opportunity> opportunities) {
        ProcessingResult result = new ProcessingResult();
        List<Opportunity> toUpdate = new List<Opportunity>();
        
        for (Opportunity opp : opportunities) {
            if (qualifiesForNudge(opp)) {
                result.qualified++;
                
                // Update the nudge timestamp
                opp.Last_Nudged_On__c = System.today();
                toUpdate.add(opp);
                
                // In a real implementation, we would also:
                // - Queue email to owner
                // - Log to custom object for audit trail
                // - Update dashboard metrics
            } else {
                result.skipped++;
            }
        }
        
        // Perform DML
        if (!toUpdate.isEmpty()) {
            try {
                update toUpdate;
                result.processed = toUpdate.size();
            } catch (DmlException e) {
                System.debug(LoggingLevel.ERROR, 'Error updating opportunities: ' + e.getMessage());
                // In production, implement proper error handling
            }
        }
        
        return result;
    }
    
    // ========== Private Helper Methods ==========
    
    /**
     * Checks if opportunity is open (not Closed Won or Closed Lost)
     */
    private Boolean isOpenOpportunity(Opportunity opp) {
        return !opp.IsClosed;
    }
    
    /**
     * Checks if opportunity has no recent activity.
     * An opportunity is stale if LastActivityDate is null or older than threshold.
     */
    private Boolean isStaleOpportunity(Opportunity opp) {
        if (opp.LastActivityDate == null) {
            return true; // No activity ever = definitely stale
        }
        
        Date threshold = System.today().addDays(-H2_StaleOpportunityNudgeConfig.STALE_ACTIVITY_DAYS);
        return opp.LastActivityDate < threshold;
    }
    
    /**
     * Checks if the Do Not Nudge flag is set.
     * This allows users to opt out specific opportunities.
     */
    private Boolean isMarkedDoNotNudge(Opportunity opp) {
        return opp.Do_Not_Nudge__c == true;
    }
    
    /**
     * Checks if we've already nudged this opportunity recently.
     * Prevents spam by enforcing a cooldown period.
     */
    private Boolean wasRecentlyNudged(Opportunity opp) {
        if (opp.Last_Nudged_On__c == null) {
            return false; // Never nudged = not recently nudged
        }
        
        Date threshold = System.today().addDays(-H2_StaleOpportunityNudgeConfig.RECENTLY_NUDGED_DAYS);
        return opp.Last_Nudged_On__c >= threshold;
    }
    
    /**
     * Checks if the opportunity owner is active.
     * Inactive users cannot receive emails or notifications,
     * so there's no point in nudging opportunities they own.
     */
    private Boolean hasActiveOwner(Opportunity opp) {
        return opp.Owner.IsActive == true;
    }
}
