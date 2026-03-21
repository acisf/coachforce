@IsTest
private class CF_CreateEvaluationResultsActionTest {

    @IsTest
    static void testRun_Success() {
        CF_Call_Evaluation__c evalRecord = makeEval(buildJson(
            'Solid call overall.',
            'Discovery',
            new List<String>{
                buildResultJson('Greeting', 'Opened Professionally', '100', 'true', 'Warm and professional opening.'),
                buildResultJson('Discovery', 'Asked Clarifying Questions', '55', 'false', 'Agent needed to explore patient needs more deeply.')
            }
        ));
        insert evalRecord;

        Test.startTest();

        CF_CreateEvaluationResultsAction.Request req = new CF_CreateEvaluationResultsAction.Request();
        req.callEvaluationId = evalRecord.Id;

        List<CF_CreateEvaluationResultsAction.Result> results =
            CF_CreateEvaluationResultsAction.run(
                new List<CF_CreateEvaluationResultsAction.Request>{ req }
            );

        Test.stopTest();

        System.assertEquals(true, results[0].success);
        System.assertEquals(2, results[0].resultsCreated);
        System.assertEquals('Solid call overall.', results[0].summary);
        System.assertEquals('Discovery', results[0].primaryCoachingTopic);

        CF_Call_Evaluation__c refreshedEval = [
            SELECT CF_AI_Summary__c
            FROM CF_Call_Evaluation__c
            WHERE Id = :evalRecord.Id
        ];
        System.assertEquals('Solid call overall.', refreshedEval.CF_AI_Summary__c);

        List<CF_Evaluation_Result__c> detailRows = [
            SELECT CF_Score__c, CF_Passed__c, CF_Feedback__c, CF_Evaluation_Criteria__c
            FROM CF_Evaluation_Result__c
            WHERE CF_Call_Evaluation__c = :evalRecord.Id
        ];

        System.assertEquals(2, detailRows.size());
    }

@IsTest
static void testRun_RebuildsExistingResults() {
    CF_Call_Evaluation__c evalRecord = makeEval(buildJson(
        'Initial summary.',
        'Greeting',
        new List<String>{
            buildResultJson('Greeting', 'Initial Criterion', '80', 'true', 'Initial feedback.')
        }
    ));
    insert evalRecord;

    CF_CreateEvaluationResultsAction.Request req = new CF_CreateEvaluationResultsAction.Request();
    req.callEvaluationId = evalRecord.Id;

    CF_CreateEvaluationResultsAction.run(
        new List<CF_CreateEvaluationResultsAction.Request>{ req }
    );

    // Update JSON to simulate rerun
    evalRecord = [
        SELECT CF_Evaluation_JSON__c
        FROM CF_Call_Evaluation__c
        WHERE Id = :evalRecord.Id
    ];

    evalRecord.CF_Evaluation_JSON__c = buildJson(
        'Updated summary.',
        'Empathy',
        new List<String>{
            buildResultJson('Empathy', 'Acknowledged Concern', '40', 'false', 'Needs stronger acknowledgement.'),
            buildResultJson('Verification', 'Confirmed Details', '95', 'true', 'Verified information clearly.')
        }
    );
    update evalRecord;

    Test.startTest();
    List<CF_CreateEvaluationResultsAction.Result> rerunResults =
        CF_CreateEvaluationResultsAction.run(
            new List<CF_CreateEvaluationResultsAction.Request>{ req }
        );
    Test.stopTest();

    System.assertEquals(true, rerunResults[0].success);
    System.assertEquals(2, rerunResults[0].resultsCreated);

    List<CF_Evaluation_Result__c> rebuiltRows = [
        SELECT CF_Evaluation_Criteria__c
        FROM CF_Evaluation_Result__c
        WHERE CF_Call_Evaluation__c = :evalRecord.Id
    ];

    System.assertEquals(2, rebuiltRows.size());
}

    @IsTest
    static void testRun_BlankJson() {
        CF_Call_Evaluation__c evalRecord = makeEval(null);
        insert evalRecord;

        CF_CreateEvaluationResultsAction.Request req = new CF_CreateEvaluationResultsAction.Request();
        req.callEvaluationId = evalRecord.Id;

        Test.startTest();
        List<CF_CreateEvaluationResultsAction.Result> results =
            CF_CreateEvaluationResultsAction.run(
                new List<CF_CreateEvaluationResultsAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(false, results[0].success);
        System.assertEquals(0, results[0].resultsCreated);

        Integer countResults = [
            SELECT COUNT()
            FROM CF_Evaluation_Result__c
            WHERE CF_Call_Evaluation__c = :evalRecord.Id
        ];

        System.assertEquals(0, countResults);
    }

    // 🔧 Helper: Create Evaluation + Transcript
    private static CF_Call_Evaluation__c makeEval(String evaluationJson) {

        CF_Call_Transcript__c transcript = new CF_Call_Transcript__c(
            CF_Transcript_Text__c = 'Test transcript',
            CF_Evaluation_Status__c = 'Pending'
        );
        insert transcript;

        CF_Call_Evaluation__c evalRecord = new CF_Call_Evaluation__c();
        evalRecord.CF_Transcript__c = transcript.Id;
        evalRecord.CF_Evaluation_JSON__c = evaluationJson;
        evalRecord.CF_Evaluation_Date__c = Date.today();

        return evalRecord;
    }

    // 🔧 Helper: Build JSON
    private static String buildJson(
        String summary,
        String topic,
        List<String> results
    ) {
        return '{' +
            '"summary":"' + summary + '",' +
            '"primaryCoachingTopic":"' + topic + '",' +
            '"results":[' + String.join(results, ',') + ']' +
        '}';
    }

    private static String buildResultJson(
        String category,
        String criteria,
        String score,
        String passed,
        String feedback
    ) {
        return '{' +
            '"category":"' + category + '",' +
            '"criteria":"' + criteria + '",' +
            '"score":' + score + ',' +
            '"passed":' + passed + ',' +
            '"feedback":"' + feedback + '"' +
        '}';
    }
}