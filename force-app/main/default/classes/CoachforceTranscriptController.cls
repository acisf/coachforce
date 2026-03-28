public with sharing class CoachforceTranscriptController {
    @AuraEnabled(cacheable=true)
    public static String getTranscriptText(Id voiceCallId) {
        if (voiceCallId == null) {
            return null;
        }

        List<CF_Call_Transcript__c> transcripts = [
            SELECT Id, CF_Transcript_Text__c
            FROM CF_Call_Transcript__c
            WHERE CF_Voice_Call__c = :voiceCallId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (transcripts.isEmpty()) {
            return null;
        }
		
        System.debug(transcripts[0].CF_Transcript_Text__c);
        return transcripts[0].CF_Transcript_Text__c;
    }
}