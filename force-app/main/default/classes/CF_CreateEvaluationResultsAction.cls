public with sharing class CF_CreateEvaluationResultsAction {

    public class Request {
        @InvocableVariable(required=true)
        public Id callEvaluationId;
    }

    public class Result {
        @InvocableVariable
        public Id callEvaluationId;

        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String message;

        @InvocableVariable
        public Integer resultsCreated;

        @InvocableVariable
        public String summary;

        @InvocableVariable
        public String primaryCoachingTopic;
    }

    private class EvaluationPayload {
        public String evaluationtemplate;
        public String agentUserId;
        public Decimal overallScore;
        public String summary;
        public String primaryCoachingTopic;
        public List<EvaluationResultItem> results;
    }

    private class EvaluationResultItem {
        public String category;
        public String criteria;
        public Boolean applicable;
        public Decimal score;
        public Decimal maxScore;
        public Boolean passed;
        public String feedback;
    }

    @InvocableMethod(
        label='Create Evaluation Results from JSON'
        description='Parses CF_Evaluation_JSON__c from CF_Call_Evaluation__c, updates evaluation fields, and creates CF_Evaluation_Result__c records.'
    )
    public static List<Result> run(List<Request> requests) {
        List<Result> output = new List<Result>();

        if (requests == null || requests.isEmpty()) {
            return output;
        }

        Set<Id> evalIds = new Set<Id>();
        for (Request req : requests) {
            if (req != null && req.callEvaluationId != null) {
                evalIds.add(req.callEvaluationId);
            }
        }

        if (evalIds.isEmpty()) {
            return output;
        }

        Map<Id, CF_Call_Evaluation__c> evaluationsById = new Map<Id, CF_Call_Evaluation__c>([
            SELECT Id,
                   CF_Evaluation_JSON__c,
                   CF_AI_Summary__c
            FROM CF_Call_Evaluation__c
            WHERE Id IN :evalIds
        ]);

        Map<Id, List<CF_Evaluation_Result__c>> existingResultsByEvalId = new Map<Id, List<CF_Evaluation_Result__c>>();
        for (CF_Evaluation_Result__c row : [
            SELECT Id, CF_Call_Evaluation__c
            FROM CF_Evaluation_Result__c
            WHERE CF_Call_Evaluation__c IN :evalIds
        ]) {
            if (!existingResultsByEvalId.containsKey(row.CF_Call_Evaluation__c)) {
                existingResultsByEvalId.put(row.CF_Call_Evaluation__c, new List<CF_Evaluation_Result__c>());
            }
            existingResultsByEvalId.get(row.CF_Call_Evaluation__c).add(row);
        }

        List<CF_Call_Evaluation__c> evalsToUpdate = new List<CF_Call_Evaluation__c>();
        List<CF_Evaluation_Result__c> resultsToInsert = new List<CF_Evaluation_Result__c>();
        List<CF_Evaluation_Result__c> resultsToDelete = new List<CF_Evaluation_Result__c>();

        Map<Id, Integer> createdCountByEvalId = new Map<Id, Integer>();
        Map<Id, String> messageByEvalId = new Map<Id, String>();
        Map<Id, String> summaryByEvalId = new Map<Id, String>();
        Map<Id, String> topicByEvalId = new Map<Id, String>();
        Set<Id> successfulEvalIds = new Set<Id>();

        for (Id evalId : evalIds) {
            CF_Call_Evaluation__c evalRecord = evaluationsById.get(evalId);

            if (evalRecord == null) {
                messageByEvalId.put(evalId, 'CF_Call_Evaluation__c not found.');
                createdCountByEvalId.put(evalId, 0);
                continue;
            }

            if (String.isBlank(evalRecord.CF_Evaluation_JSON__c)) {
                messageByEvalId.put(evalId, 'CF_Evaluation_JSON__c is blank.');
                createdCountByEvalId.put(evalId, 0);
                continue;
            }

            try {
                EvaluationPayload payload =
                    (EvaluationPayload) JSON.deserialize(evalRecord.CF_Evaluation_JSON__c, EvaluationPayload.class);

                if (existingResultsByEvalId.containsKey(evalId)) {
                    resultsToDelete.addAll(existingResultsByEvalId.get(evalId));
                }

                CF_Call_Evaluation__c evalToUpdate = new CF_Call_Evaluation__c(
                    Id = evalId,
                    CF_AI_Summary__c = payload.summary
                );
                evalsToUpdate.add(evalToUpdate);

                Integer createdCount = 0;

                if (payload.results != null) {
                    for (EvaluationResultItem item : payload.results) {
                        CF_Evaluation_Result__c detail = new CF_Evaluation_Result__c();
                        detail.CF_Call_Evaluation__c = evalId;
                        detail.CF_Criterion_Category__c = item.category;
                        detail.CF_Evaluation_Criteria__c = item.criteria;
                        detail.CF_Applicable__c = item.applicable == null ? true : item.applicable;
                        detail.CF_Score__c = item.score == null ? 0 : item.score;
                        detail.CF_Possible_Points__c = item.maxScore == null ? 0 : item.maxScore;
                        detail.CF_Passed__c = item.passed == null ? false : item.passed;
                        detail.CF_Feedback__c = item.feedback;

                        resultsToInsert.add(detail);
                        createdCount++;
                    }
                }

                createdCountByEvalId.put(evalId, createdCount);
                messageByEvalId.put(evalId, 'Success');
                summaryByEvalId.put(evalId, payload.summary);
                topicByEvalId.put(evalId, payload.primaryCoachingTopic);
                successfulEvalIds.add(evalId);

            } catch (Exception e) {
                messageByEvalId.put(evalId, 'JSON parse failed: ' + e.getMessage());
                createdCountByEvalId.put(evalId, 0);
            }
        }

        if (!resultsToDelete.isEmpty()) {
            delete resultsToDelete;
        }

        if (!evalsToUpdate.isEmpty()) {
            update evalsToUpdate;
        }

        if (!resultsToInsert.isEmpty()) {
            insert resultsToInsert;
        }

        for (Request req : requests) {
            Result r = new Result();
            r.callEvaluationId = req.callEvaluationId;
            r.success = successfulEvalIds.contains(req.callEvaluationId);
            r.message = messageByEvalId.get(req.callEvaluationId);
            r.resultsCreated = createdCountByEvalId.containsKey(req.callEvaluationId)
                ? createdCountByEvalId.get(req.callEvaluationId)
                : 0;
            r.summary = summaryByEvalId.get(req.callEvaluationId);
            r.primaryCoachingTopic = topicByEvalId.get(req.callEvaluationId);
            output.add(r);
        }

        return output;
    }
}