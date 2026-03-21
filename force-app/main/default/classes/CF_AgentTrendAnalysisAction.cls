public with sharing class CF_AgentTrendAnalysisAction {

    public class Request {
        @InvocableVariable(required=true)
        public Id agentId;

        @InvocableVariable
        public Integer lookbackEvaluations;

        @InvocableVariable
        public Decimal thresholdPercent;
    }

    public class Response {
        @InvocableVariable
        public Boolean foundTrend;

        @InvocableVariable
        public String criterionText;

        @InvocableVariable
        public Integer totalCount;

        @InvocableVariable
        public Integer failedCount;

        @InvocableVariable
        public Decimal passPercent;

        @InvocableVariable
        public String summaryMessage;
    }

    private class TrendStats {
        String criterionText;
        Integer totalCount = 0;
        Integer failedCount = 0;

        Decimal getPassPercent() {
            if (totalCount == 0) {
                return 0;
            }

            Decimal passedCount = totalCount - failedCount;
            return (passedCount / totalCount) * 100;
        }
    }

    @InvocableMethod(
        label='Analyze Agent Trends'
        description='Returns the lowest-performing evaluation criterion for an agent below a threshold.'
    )
    public static List<Response> analyzeAgentTrends(List<Request> requests) {
        List<Response> responses = new List<Response>();

        for (Request req : requests) {
            responses.add(analyzeSingle(req));
        }

        return responses;
    }

    private static Response analyzeSingle(Request req) {
        Response res = new Response();
        res.foundTrend = false;

        if (req == null || req.agentId == null) {
            res.summaryMessage = 'No agentId was provided.';
            return res;
        }

        Integer lookbackEvaluations = (req.lookbackEvaluations == null || req.lookbackEvaluations <= 0)
            ? 10
            : req.lookbackEvaluations;

        Decimal thresholdPercent = (req.thresholdPercent == null)
            ? 70
            : req.thresholdPercent;

        List<CF_Call_Evaluation__c> evaluations = [
            SELECT Id
            FROM CF_Call_Evaluation__c
            WHERE CF_Agent__c = :req.agentId
            ORDER BY CreatedDate DESC
            LIMIT :lookbackEvaluations
        ];

        if (evaluations.isEmpty()) {
            res.summaryMessage = 'No recent call evaluations found for the agent.';
            return res;
        }

        Set<Id> evaluationIds = new Set<Id>();
        for (CF_Call_Evaluation__c evalRec : evaluations) {
            evaluationIds.add(evalRec.Id);
        }

        List<CF_Evaluation_Result__c> results = [
            SELECT Id,
                   CF_Call_Evaluation__c,
                   CF_Passed__c,
                   CF_Evaluation_Criteria__c
            FROM CF_Evaluation_Result__c
            WHERE CF_Call_Evaluation__c IN :evaluationIds
              AND CF_Evaluation_Criteria__c != null
        ];

        if (results.isEmpty()) {
            res.summaryMessage = 'No evaluation results found for the recent call evaluations.';
            return res;
        }

        Map<String, TrendStats> statsByCriterion = new Map<String, TrendStats>();

        for (CF_Evaluation_Result__c row : results) {
            String criterionText = row.CF_Evaluation_Criteria__c;

            if (String.isBlank(criterionText)) {
                continue;
            }

            if (!statsByCriterion.containsKey(criterionText)) {
                TrendStats stat = new TrendStats();
                stat.criterionText = criterionText;
                statsByCriterion.put(criterionText, stat);
            }

            TrendStats stat = statsByCriterion.get(criterionText);
            stat.totalCount++;

            if (row.CF_Passed__c == false) {
                stat.failedCount++;
            }
        }

        TrendStats worstStat;
        Decimal worstPassPercent;

        for (TrendStats stat : statsByCriterion.values()) {
            Decimal passPct = stat.getPassPercent();

            if (passPct < thresholdPercent) {
                if (worstStat == null || passPct < worstPassPercent) {
                    worstStat = stat;
                    worstPassPercent = passPct;
                }
            }
        }

        if (worstStat == null) {
            res.summaryMessage = 'No criterion fell below the threshold of ' + thresholdPercent + '%.';
            return res;
        }

        res.foundTrend = true;
        res.criterionText = worstStat.criterionText;
        res.totalCount = worstStat.totalCount;
        res.failedCount = worstStat.failedCount;
        res.passPercent = worstStat.getPassPercent();
        res.summaryMessage =
            'Lowest-performing criterion is "' + res.criterionText +
            '" with pass rate ' + res.passPercent +
            '% (' + res.failedCount + ' failed out of ' + res.totalCount + ').';

        return res;
    }
}