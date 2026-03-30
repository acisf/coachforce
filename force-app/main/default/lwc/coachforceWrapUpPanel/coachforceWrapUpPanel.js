import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CoachforceWrapUpPanel extends LightningElement {
    @api recordId;

    isSaving = false;
    statusMessage = 'Saving your call';
    dotCount = 0;
    statusInterval;

    statusSteps = [
        'Saving your call',
        'Analyzing transcript',
        'Scoring against evaluation criteria',
        'Generating coaching session'
    ];

    get saveButtonLabel() {
        return this.isSaving ? 'Saving...' : 'Save';
    }

    get animatedStatusMessage() {
        return `${this.statusMessage}${'.'.repeat(this.dotCount + 1)}`;
    }

    handleSubmit() {
        this.isSaving = true;
        this.startSavingStatus();
    }

    handleSuccess() {
        this.isSaving = false;
        this.stopSavingStatus();

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Saved',
                message: 'Call wrapped up! Check for a coaching session in your notifications.',
                variant: 'success'
            })
        );
    }

    handleError(event) {
        this.isSaving = false;
        this.stopSavingStatus();

        let message = 'Unable to save call wrap-up.';
        if (event?.detail?.message) {
            message = event.detail.message;
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message,
                variant: 'error'
            })
        );
    }

    startSavingStatus() {
        this.stopSavingStatus();

        let stepIndex = 0;
        this.statusMessage = this.statusSteps[stepIndex];
        this.dotCount = 0;

        this.statusInterval = window.setInterval(() => {
            this.dotCount = (this.dotCount + 1) % 3;

            if (stepIndex < this.statusSteps.length - 1) {
                stepIndex += 1;
                this.statusMessage = this.statusSteps[stepIndex];
            } else {
                this.statusMessage = this.statusSteps[this.statusSteps.length - 1];
            }
        }, 4000);
    }

    stopSavingStatus() {
        if (this.statusInterval) {
            clearInterval(this.statusInterval);
            this.statusInterval = null;
        }
        this.statusMessage = 'Saving your call';
        this.dotCount = 0;
    }

    disconnectedCallback() {
        this.stopSavingStatus();
    }
}