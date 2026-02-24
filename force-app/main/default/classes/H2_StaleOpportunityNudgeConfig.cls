/**
 * Configuration constants for the Stale Opportunity Nudge batch process.
 * Centralizes business rules and thresholds to make maintenance easier.
 */
public class H2_StaleOpportunityNudgeConfig {
    
    // An opportunity is considered "stale" if no activity in this many days
    public static final Integer STALE_ACTIVITY_DAYS = 14;
    
    // Don't nudge again if we nudged within this many days
    public static final Integer RECENTLY_NUDGED_DAYS = 7;
    
    // Default batch size for processing
    public static final Integer DEFAULT_BATCH_SIZE = 200;
    
    // Query scope for batch job
    public static final String BATCH_QUERY = 
        'SELECT Id, Name, Amount, StageName, ' +
        '       Owner.Id, Owner.Name, Owner.IsActive, Owner.Email, ' +
        '       LastActivityDate, Last_Nudged_On__c, Do_Not_Nudge__c ' +
        'FROM Opportunity ' +
        'WHERE IsClosed = false ' +
        'ORDER BY LastActivityDate ASC NULLS FIRST';
    
    // Email template settings (for future email integration)
    public static final String NUDGE_EMAIL_TEMPLATE = 'Stale_Opportunity_Reminder';
    
    /**
     * Returns the display name for logging and monitoring
     */
    public static String getJobDisplayName() {
        return 'Stale Opportunity Nudge Batch';
    }
}
