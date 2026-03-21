@IsTest
private class CF_CreateCoachingSessionActionTest {

    @IsTest
    static void testRun_Success() {
        CF_Coaching_Session__c sessionRecord = makeSession(buildCoachingJson(
            'Discovery',
            'The agent maintained a friendly tone and greeted the caller well.',
            'The agent did not ask enough follow-up questions to understand the caller\'s needs.',
            'I\'d like to ask a couple of quick questions so I can better understand what you\'re looking for and guide you to the best next step.',
            'Roleplay a caller who is unsure what service they need and is hesitant to book.'
        ));
        insert sessionRecord;

        CF_CreateCoachingSessionAction.Request req = new CF_CreateCoachingSessionAction.Request();
        req.coachingSessionId = sessionRecord.Id;

        Test.startTest();
        List<CF_CreateCoachingSessionAction.Result> results =
            CF_CreateCoachingSessionAction.run(
                new List<CF_CreateCoachingSessionAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        System.assertEquals('Success', results[0].message);
        System.assertEquals('Discovery', results[0].coachingTopic);

        CF_Coaching_Session__c refreshed = [
            SELECT CF_Coaching_JSON__c,
                   CF_Coaching_Topic__c,
                   CF_What_Went_Well__c,
                   CF_Improvement_Area__c,
                   CF_Improved_Script__c,
                   CF_Rehearsal_Scenario__c
            FROM CF_Coaching_Session__c
            WHERE Id = :sessionRecord.Id
        ];

        System.assertEquals('Discovery', refreshed.CF_Coaching_Topic__c);
        System.assertEquals(
            'The agent maintained a friendly tone and greeted the caller well.',
            refreshed.CF_What_Went_Well__c
        );
        System.assertEquals(
            'The agent did not ask enough follow-up questions to understand the caller\'s needs.',
            refreshed.CF_Improvement_Area__c
        );
        System.assertEquals(
            'I\'d like to ask a couple of quick questions so I can better understand what you\'re looking for and guide you to the best next step.',
            refreshed.CF_Improved_Script__c
        );
        System.assertEquals(
            'Roleplay a caller who is unsure what service they need and is hesitant to book.',
            refreshed.CF_Rehearsal_Scenario__c
        );
    }

    @IsTest
    static void testRun_BlankJson() {
        CF_Coaching_Session__c sessionRecord = makeSession(null);
        insert sessionRecord;

        CF_CreateCoachingSessionAction.Request req = new CF_CreateCoachingSessionAction.Request();
        req.coachingSessionId = sessionRecord.Id;

        Test.startTest();
        List<CF_CreateCoachingSessionAction.Result> results =
            CF_CreateCoachingSessionAction.run(
                new List<CF_CreateCoachingSessionAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        System.assertEquals('CF_Coaching_JSON__c is blank.', results[0].message);
        System.assertEquals(null, results[0].coachingTopic);

        CF_Coaching_Session__c refreshed = [
            SELECT CF_Coaching_Topic__c,
                   CF_What_Went_Well__c,
                   CF_Improvement_Area__c,
                   CF_Improved_Script__c,
                   CF_Rehearsal_Scenario__c
            FROM CF_Coaching_Session__c
            WHERE Id = :sessionRecord.Id
        ];

        System.assertEquals(null, refreshed.CF_Coaching_Topic__c);
        System.assertEquals(null, refreshed.CF_What_Went_Well__c);
        System.assertEquals(null, refreshed.CF_Improvement_Area__c);
        System.assertEquals(null, refreshed.CF_Improved_Script__c);
        System.assertEquals(null, refreshed.CF_Rehearsal_Scenario__c);
    }

    @IsTest
    static void testRun_InvalidJson() {
        CF_Coaching_Session__c sessionRecord = makeSession('{not valid json}');
        insert sessionRecord;

        CF_CreateCoachingSessionAction.Request req = new CF_CreateCoachingSessionAction.Request();
        req.coachingSessionId = sessionRecord.Id;

        Test.startTest();
        List<CF_CreateCoachingSessionAction.Result> results =
            CF_CreateCoachingSessionAction.run(
                new List<CF_CreateCoachingSessionAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        System.assert(results[0].message != null && results[0].message.startsWith('JSON parse failed:'));
        System.assertEquals(null, results[0].coachingTopic);
    }

    private static CF_Coaching_Session__c makeSession(String coachingJson) {
        CF_Coaching_Session__c sessionRecord = new CF_Coaching_Session__c();
        sessionRecord.CF_Coaching_JSON__c = coachingJson;
        return sessionRecord;
    }

    private static String buildCoachingJson(
        String coachingTopic,
        String whatWentWell,
        String improvementArea,
        String improvedScript,
        String rehearsalScenario
    ) {
        return '{' +
            '"coachingTopic":"' + escapeJson(coachingTopic) + '",' +
            '"whatWentWell":"' + escapeJson(whatWentWell) + '",' +
            '"improvementArea":"' + escapeJson(improvementArea) + '",' +
            '"improvedScript":"' + escapeJson(improvedScript) + '",' +
            '"rehearsalScenario":"' + escapeJson(rehearsalScenario) + '"' +
        '}';
    }

    private static String escapeJson(String value) {
        if (value == null) {
            return '';
        }

        return value
            .replace('\\', '\\\\')
            .replace('"', '\\"')
            .replace('\r', '\\r')
            .replace('\n', '\\n')
            .replace('\t', '\\t');
    }
}