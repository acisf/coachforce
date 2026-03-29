@IsTest
private class CF_TranscriptControllerTest {

    @IsTest
    static void testGetTranscriptText_ReturnsLatestTranscript() {
        // Create a voice call
        CF_Voice_Call__c voiceCall = new CF_Voice_Call__c();
        insert voiceCall;

        // Older transcript
        CF_Call_Transcript__c transcript = new CF_Call_Transcript__c(
            CF_Voice_Call__c = voiceCall.Id,
            CF_Transcript_Text__c = 'Agent: Hello, thank you for calling.'
        );
        insert transcript;

        Test.startTest();
        String result = CF_TranscriptController.getTranscriptText(voiceCall.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Expected transcript text to be returned.');
        
        System.assertEquals(
            'Agent: Hello, thank you for calling.',
            result,
            'Expected the most recently created transcript text to be returned.'
        );
    }

    @IsTest
    static void testGetTranscriptText_ReturnsNullWhenNoTranscriptExists() {
        // Create a voice call with no transcripts
        CF_Voice_Call__c voiceCall = new CF_Voice_Call__c();
        insert voiceCall;

        Test.startTest();
        String result = CF_TranscriptController.getTranscriptText(voiceCall.Id);
        Test.stopTest();

        System.assertEquals(null, result, 'Expected null when no transcript exists.');
    }

    @IsTest
    static void testGetTranscriptText_ReturnsNullWhenVoiceCallIdIsNull() {
        Test.startTest();
        String result = CF_TranscriptController.getTranscriptText(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Expected null when voiceCallId is null.');
    }
}