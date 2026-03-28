import { LightningElement, api, wire } from 'lwc';
import getTranscriptText from '@salesforce/apex/CoachforceTranscriptController.getTranscriptText';

export default class CoachforceTranscriptPanel extends LightningElement {
    @api recordId;

    transcriptText;
    error;
    messages = [];

    @wire(getTranscriptText, { voiceCallId: '$recordId' })
    wiredTranscript({ error, data }) {
        console.log('recordId', this.recordId);
        console.log('wire data', data);
        console.log('wire error', error);

        if (data) {
            this.transcriptText = data;
            this.error = undefined;
            this.messages = this.parseTranscript(data);
        } else if (error) {
            this.error = error;
            this.transcriptText = null;
            this.messages = [];
        }
    }

    get hasMessages() {
        return this.messages && this.messages.length > 0;
    }

    get hasNoMessages() {
        return !this.hasMessages;
    }

    parseTranscript(rawText) {
        if (!rawText) {
            return [];
        }

                    console.log('Raw transcript text:', rawText);

        const lines = rawText
            .split(/\r?\n/)
            .map(line => line.trim())
            .filter(line => line.length > 0);

        return lines.map((line, index) => {
            let speaker = 'Unknown';
            let text = line;

            const match = line.match(/^(Agent|Caller)\s*:\s*(.*)$/i);
            if (match) {
                speaker = match[1];
                text = match[2];
            }

            const isAgent = speaker.toLowerCase() === 'agent';

            return {
                id: `${index}`,
                speaker,
                speakerLabel: isAgent ? 'Agent' : 'Caller',
                text,
                timestamp: this.buildFakeTimestamp(index),
                rowClass: isAgent ? 'message-row agent' : 'message-row caller',
                bubbleClass: isAgent ? 'message-bubble agent-bubble' : 'message-bubble caller-bubble'
            };
        });
    }

    buildFakeTimestamp(index) {
        const startHour = 10;
        const startMinute = 0 + index;

        const hours24 = startHour + Math.floor(startMinute / 60);
        const minutes = startMinute % 60;

        const suffix = hours24 >= 12 ? 'PM' : 'AM';
        const hours12 = ((hours24 + 11) % 12) + 1;

        return `${hours12}:${String(minutes).padStart(2, '0')} ${suffix}`;
    }
}