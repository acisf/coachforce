import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CoachforceWrapUpPanel extends LightningElement {
    @api recordId;

    isSaving = false;

    get saveButtonLabel() {
        return this.isSaving ? 'Saving...' : 'Save';
    }

    handleSubmit() {
        this.isSaving = true;
    }

    handleSuccess() {
        this.isSaving = false;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Saved',
                message: 'Call wrapped up!',
                variant: 'success'
            })
        );
    }

    handleError(event) {
        this.isSaving = false;

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
}