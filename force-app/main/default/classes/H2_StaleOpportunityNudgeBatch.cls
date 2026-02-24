/**
 * Batch job to identify and nudge stale opportunities.
 * 
 * This job runs nightly to find opportunities that haven't had recent activity
 * and updates them with a nudge timestamp. In production, this would also
 * trigger email notifications to opportunity owners.
 * 
 * Implements Database.Stateful to track metrics across batch iterations.
 */
public class H2_StaleOpportunityNudgeBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    // Stateful counters to track across all batch iterations
    private Integer totalRecordsProcessed = 0;
    private Integer totalRecordsQualified = 0;
    private Integer totalRecordsSkipped = 0;
    private Integer totalRecordsQueried = 0;
    
    private H2_StaleOpportunityNudgeService service;
    
    /**
     * Constructor initializes the service layer
     */
    public H2_StaleOpportunityNudgeBatch() {
        this.service = new H2_StaleOpportunityNudgeService();
    }
    
    /**
     * Start method: Returns query locator with all open opportunities
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO, 
            'Starting ' + H2_StaleOpportunityNudgeConfig.getJobDisplayName());
        
        return Database.getQueryLocator(H2_StaleOpportunityNudgeConfig.BATCH_QUERY);
    }
    
    /**
     * Execute method: Processes each batch of opportunities
     * 
     * @param BC Batchable context
     * @param scope List of opportunity records for this batch iteration
     */
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        totalRecordsQueried += scope.size();
        
        System.debug(LoggingLevel.INFO, 
            'Processing batch of ' + scope.size() + ' opportunities');
        
        // Delegate to service layer for business logic
        H2_StaleOpportunityNudgeService.ProcessingResult result = 
            service.processOpportunities(scope);
        
        // Update stateful counters
        totalRecordsQualified += result.qualified;
        totalRecordsProcessed += result.processed;
        totalRecordsSkipped += result.skipped;
        
        System.debug(LoggingLevel.DEBUG, 
            'Batch iteration complete. Qualified: ' + result.qualified + 
            ', Processed: ' + result.processed + 
            ', Skipped: ' + result.skipped);
    }
    
    /**
     * Finish method: Logs final statistics and summary
     * 
     * In a production system, this would:
     * - Send summary email to administrators
     * - Update custom monitoring dashboard
     * - Log to custom object for historical tracking
     */
    public void finish(Database.BatchableContext BC) {
        // Get job info for logging
        AsyncApexJob jobInfo = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
            FROM AsyncApexJob 
            WHERE Id = :BC.getJobId()
        ];
        
        // Generate summary message
        String summary = buildSummaryMessage(jobInfo);
        
        System.debug(LoggingLevel.INFO, summary);
        
        // In production, send email to admins
        // sendSummaryEmail(summary);
        
        // In production, log to custom object for historical tracking
        // logBatchExecution(jobInfo);
    }
    
    /**
     * Builds a human-readable summary of the batch execution
     */
    private String buildSummaryMessage(AsyncApexJob jobInfo) {
        String summary = '\n========================================\n';
        summary += H2_StaleOpportunityNudgeConfig.getJobDisplayName() + ' - Summary\n';
        summary += '========================================\n';
        summary += 'Job ID: ' + jobInfo.Id + '\n';
        summary += 'Status: ' + jobInfo.Status + '\n';
        summary += 'Batch Iterations: ' + jobInfo.JobItemsProcessed + ' of ' + jobInfo.TotalJobItems + '\n';
        summary += 'Errors: ' + jobInfo.NumberOfErrors + '\n';
        summary += '----------------------------------------\n';
        summary += 'Total Records Queried: ' + totalRecordsQueried + '\n';
        summary += 'Total Records Qualified: ' + totalRecordsQualified + '\n';
        summary += 'Total Records Processed: ' + totalRecordsProcessed + '\n';
        summary += 'Total Records Skipped: ' + totalRecordsSkipped + '\n';
        summary += '========================================\n';
        
        return summary;
    }
}
