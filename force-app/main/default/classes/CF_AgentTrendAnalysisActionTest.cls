@IsTest
private class CF_AgentTrendAnalysisActionTest {

    @TestSetup
    static void setupData() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        List<CF_Call_Evaluation__c> evals = new List<CF_Call_Evaluation__c>();
        for (Integer i = 0; i < 3; i++) {
            evals.add(new CF_Call_Evaluation__c(
                CF_Agent__c = u.Id
            ));
        }
        insert evals;

        List<CF_Evaluation_Result__c> results = new List<CF_Evaluation_Result__c>{
            // Greeting = 1 pass, 2 fail = 33.33%
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[0].Id,
                CF_Evaluation_Criteria__c = 'Greeting',
                CF_Passed__c = false,
                CF_Applicable__c = true
            ),
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[1].Id,
                CF_Evaluation_Criteria__c = 'Greeting',
                CF_Passed__c = false,
                CF_Applicable__c = true
            ),
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[2].Id,
                CF_Evaluation_Criteria__c = 'Greeting',
                CF_Passed__c = true,
                CF_Applicable__c = true
            ),

            // Closing = 2 pass, 1 fail = 66.67%
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[0].Id,
                CF_Evaluation_Criteria__c = 'Closing',
                CF_Passed__c = true,
                CF_Applicable__c = true
            ),
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[1].Id,
                CF_Evaluation_Criteria__c = 'Closing',
                CF_Passed__c = true,
                CF_Applicable__c = true
            ),
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[2].Id,
                CF_Evaluation_Criteria__c = 'Closing',
                CF_Passed__c = false,
                CF_Applicable__c = true
            ),

            // Compliance = 3 pass, 0 fail = 100%
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[0].Id,
                CF_Evaluation_Criteria__c = 'Compliance',
                CF_Passed__c = true,
                CF_Applicable__c = true
            ),
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[1].Id,
                CF_Evaluation_Criteria__c = 'Compliance',
                CF_Passed__c = true,
                CF_Applicable__c = true
            ),
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[2].Id,
                CF_Evaluation_Criteria__c = 'Compliance',
                CF_Passed__c = true,
                CF_Applicable__c = true
            ),

            // Non-applicable rows should be ignored completely
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[0].Id,
                CF_Evaluation_Criteria__c = 'Irate Handling',
                CF_Passed__c = false,
                CF_Applicable__c = false
            ),
            new CF_Evaluation_Result__c(
                CF_Call_Evaluation__c = evals[1].Id,
                CF_Evaluation_Criteria__c = 'Irate Handling',
                CF_Passed__c = false,
                CF_Applicable__c = false
            )
        };
        insert results;
    }

    @IsTest
    static void testAnalyzeAgentTrends_FindsLowestCriterionBelowThreshold() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        CF_AgentTrendAnalysisAction.Request req = new CF_AgentTrendAnalysisAction.Request();
        req.agentId = u.Id;
        req.lookbackEvaluations = 10;
        req.thresholdPercent = 70;

        Test.startTest();
        List<CF_AgentTrendAnalysisAction.Response> responses =
            CF_AgentTrendAnalysisAction.analyzeAgentTrends(
                new List<CF_AgentTrendAnalysisAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, responses.size());

        CF_AgentTrendAnalysisAction.Response res = responses[0];
        System.assertEquals(true, res.foundTrend);
        System.assertEquals('Greeting', res.criterionText);
        System.assertEquals(3, res.totalCount);
        System.assertEquals(2, res.failedCount);
        System.assert(res.passPercent < 70, 'Expected Greeting pass percent to be below threshold.');
        System.assert(res.summaryMessage.contains('Greeting'), 'Summary should reference Greeting.');
    }

    @IsTest
    static void testAnalyzeAgentTrends_NoCriterionBelowThreshold() {
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        CF_AgentTrendAnalysisAction.Request req = new CF_AgentTrendAnalysisAction.Request();
        req.agentId = u.Id;
        req.lookbackEvaluations = 10;
        req.thresholdPercent = 30;

        Test.startTest();
        List<CF_AgentTrendAnalysisAction.Response> responses =
            CF_AgentTrendAnalysisAction.analyzeAgentTrends(
                new List<CF_AgentTrendAnalysisAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, responses.size());

        CF_AgentTrendAnalysisAction.Response res = responses[0];
        System.assertEquals(false, res.foundTrend);
        System.assertEquals(
            'No applicable criterion fell below the threshold of 30%.',
            res.summaryMessage
        );
    }

    @IsTest
    static void testAnalyzeAgentTrends_NoAgentId() {
        CF_AgentTrendAnalysisAction.Request req = new CF_AgentTrendAnalysisAction.Request();
        req.lookbackEvaluations = 10;
        req.thresholdPercent = 70;

        Test.startTest();
        List<CF_AgentTrendAnalysisAction.Response> responses =
            CF_AgentTrendAnalysisAction.analyzeAgentTrends(
                new List<CF_AgentTrendAnalysisAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, responses.size());

        CF_AgentTrendAnalysisAction.Response res = responses[0];
        System.assertEquals(false, res.foundTrend);
        System.assertEquals('No agentId was provided.', res.summaryMessage);
    }

    @IsTest
    static void testAnalyzeAgentTrends_NoEvaluationsFound() {
        Id fakeUserId = UserInfo.getOrganizationId().substring(0, 15).replace('00D', '005');

        CF_AgentTrendAnalysisAction.Request req = new CF_AgentTrendAnalysisAction.Request();
        req.agentId = fakeUserId;
        req.lookbackEvaluations = 10;
        req.thresholdPercent = 70;

        Test.startTest();
        List<CF_AgentTrendAnalysisAction.Response> responses =
            CF_AgentTrendAnalysisAction.analyzeAgentTrends(
                new List<CF_AgentTrendAnalysisAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, responses.size());

        CF_AgentTrendAnalysisAction.Response res = responses[0];
        System.assertEquals(false, res.foundTrend);
        System.assertEquals('No recent call evaluations found for the agent.', res.summaryMessage);
    }

    @IsTest
    static void testAnalyzeAgentTrends_NoResultsFound() {
        Profile p = [SELECT Id FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];

        User fakeUser = new User(
            Alias = 'tuser',
            Email = 'trendtestuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TrendTest',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'trendtestuser' + System.currentTimeMillis() + '@example.com'
        );
        insert fakeUser;

        CF_Call_Evaluation__c evalWithoutResults = new CF_Call_Evaluation__c(
            CF_Agent__c = fakeUser.Id
        );
        insert evalWithoutResults;

        CF_AgentTrendAnalysisAction.Request req = new CF_AgentTrendAnalysisAction.Request();
        req.agentId = fakeUser.Id;
        req.lookbackEvaluations = 1;
        req.thresholdPercent = 70;

        Test.startTest();
        List<CF_AgentTrendAnalysisAction.Response> responses =
            CF_AgentTrendAnalysisAction.analyzeAgentTrends(
                new List<CF_AgentTrendAnalysisAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, responses.size());

        CF_AgentTrendAnalysisAction.Response res = responses[0];
        System.assertEquals(false, res.foundTrend);
        System.assertEquals('No evaluation results found for the recent call evaluations.', res.summaryMessage);
    }

    @IsTest
    static void testAnalyzeAgentTrends_OnlyNonApplicableResults() {
        Profile p = [SELECT Id FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];

        User fakeUser = new User(
            Alias = 'nauser',
            Email = 'trendnauser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TrendNA',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'trendnauser' + System.currentTimeMillis() + '@example.com'
        );
        insert fakeUser;

        CF_Call_Evaluation__c evalWithOnlyNA = new CF_Call_Evaluation__c(
            CF_Agent__c = fakeUser.Id
        );
        insert evalWithOnlyNA;

        insert new CF_Evaluation_Result__c(
            CF_Call_Evaluation__c = evalWithOnlyNA.Id,
            CF_Evaluation_Criteria__c = 'Irate Handling',
            CF_Passed__c = false,
            CF_Applicable__c = false
        );

        CF_AgentTrendAnalysisAction.Request req = new CF_AgentTrendAnalysisAction.Request();
        req.agentId = fakeUser.Id;
        req.lookbackEvaluations = 1;
        req.thresholdPercent = 70;

        Test.startTest();
        List<CF_AgentTrendAnalysisAction.Response> responses =
            CF_AgentTrendAnalysisAction.analyzeAgentTrends(
                new List<CF_AgentTrendAnalysisAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, responses.size());

        CF_AgentTrendAnalysisAction.Response res = responses[0];
        System.assertEquals(false, res.foundTrend);
        System.assertEquals(
            'No applicable evaluation results were found for the recent call evaluations.',
            res.summaryMessage
        );
    }
}