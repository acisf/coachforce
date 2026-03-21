public with sharing class CF_CreateCoachingSessionAction {

    public class Request {
        @InvocableVariable(required=true)
        public Id coachingSessionId;
    }

    public class Result {
        @InvocableVariable
        public Id coachingSessionId;

        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String message;

        @InvocableVariable
        public String coachingTopic;
    }

    private class CoachingPayload {
        public String coachingTopic;
        public String whatWentWell;
        public String improvementArea;
        public String improvedScript;
        public String rehearsalScenario;
    }

    @InvocableMethod(
        label='Update Coaching Session from JSON'
        description='Parses CF_Coaching_JSON__c from CF_Coaching_Session__c and updates the coaching fields.'
    )
    public static List<Result> run(List<Request> requests) {
        List<Result> output = new List<Result>();

        if (requests == null || requests.isEmpty()) {
            return output;
        }

        Set<Id> sessionIds = new Set<Id>();
        for (Request req : requests) {
            if (req != null && req.coachingSessionId != null) {
                sessionIds.add(req.coachingSessionId);
            }
        }

        if (sessionIds.isEmpty()) {
            return output;
        }

        Map<Id, CF_Coaching_Session__c> sessionsById = new Map<Id, CF_Coaching_Session__c>([
            SELECT Id,
                   CF_Coaching_JSON__c,
                   CF_Coaching_Topic__c,
                   CF_What_Went_Well__c,
                   CF_Improvement_Area__c,
                   CF_Improved_Script__c,
                   CF_Rehearsal_Scenario__c
            FROM CF_Coaching_Session__c
            WHERE Id IN :sessionIds
        ]);

        List<CF_Coaching_Session__c> sessionsToUpdate = new List<CF_Coaching_Session__c>();
        Map<Id, String> messageById = new Map<Id, String>();
        Map<Id, String> topicById = new Map<Id, String>();
        Set<Id> successfulIds = new Set<Id>();

        for (Id sessionId : sessionIds) {
            CF_Coaching_Session__c sessionRecord = sessionsById.get(sessionId);

            if (sessionRecord == null) {
                messageById.put(sessionId, 'CF_Coaching_Session__c not found.');
                continue;
            }

            if (String.isBlank(sessionRecord.CF_Coaching_JSON__c)) {
                messageById.put(sessionId, 'CF_Coaching_JSON__c is blank.');
                continue;
            }

            try {
                CoachingPayload payload =
                    (CoachingPayload) JSON.deserialize(sessionRecord.CF_Coaching_JSON__c, CoachingPayload.class);

                sessionsToUpdate.add(new CF_Coaching_Session__c(
                    Id = sessionId,
                    CF_Coaching_Topic__c = payload.coachingTopic,
                    CF_What_Went_Well__c = payload.whatWentWell,
                    CF_Improvement_Area__c = payload.improvementArea,
                    CF_Improved_Script__c = payload.improvedScript,
                    CF_Rehearsal_Scenario__c = payload.rehearsalScenario
                ));

                messageById.put(sessionId, 'Success');
                topicById.put(sessionId, payload.coachingTopic);
                successfulIds.add(sessionId);

            } catch (Exception e) {
                messageById.put(sessionId, 'JSON parse failed: ' + e.getMessage());
            }
        }

        if (!sessionsToUpdate.isEmpty()) {
            update sessionsToUpdate;
        }

        for (Request req : requests) {
            Result r = new Result();
            r.coachingSessionId = req.coachingSessionId;
            r.success = successfulIds.contains(req.coachingSessionId);
            r.message = messageById.get(req.coachingSessionId);
            r.coachingTopic = topicById.get(req.coachingSessionId);
            output.add(r);
        }

        return output;
    }
}