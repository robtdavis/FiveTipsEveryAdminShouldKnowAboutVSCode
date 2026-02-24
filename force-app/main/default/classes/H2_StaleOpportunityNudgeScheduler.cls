/**
 * Schedulable class to launch the Stale Opportunity Nudge batch job.
 * 
 * Usage:
 *   // Schedule to run nightly at 2:00 AM
 *   String cronExpression = '0 0 2 * * ?';
 *   System.schedule('Nightly Stale Opportunity Nudge', 
 *                   cronExpression, 
 *                   new H2_StaleOpportunityNudgeScheduler());
 * 
 * Alternative execution methods:
 *   // Run immediately (for testing)
 *   Database.executeBatch(new H2_StaleOpportunityNudgeBatch(), 200);
 * 
 *   // Run with custom batch size
 *   Database.executeBatch(new H2_StaleOpportunityNudgeBatch(), 50);
 */
public with sharing class H2_StaleOpportunityNudgeScheduler implements Schedulable {
    
    /**
     * Execute method called by the scheduler
     */
    public void execute(SchedulableContext SC) {
        System.debug(LoggingLevel.INFO, 
            'Scheduler triggered: ' + H2_StaleOpportunityNudgeConfig.getJobDisplayName());
        
        // Launch the batch job with configured batch size
        H2_StaleOpportunityNudgeBatch batch = new H2_StaleOpportunityNudgeBatch();
        Database.executeBatch(batch, H2_StaleOpportunityNudgeConfig.DEFAULT_BATCH_SIZE);
    }
}
