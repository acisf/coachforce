import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

// Voice Call fields
import RELATED_RECORD_FIELD from '@salesforce/schema/CF_Voice_Call__c.CF_Related_Record__c';

// Contact fields
import CONTACT_NAME_FIELD from '@salesforce/schema/Contact.Name';
import CONTACT_PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import CONTACT_MAILING_STREET_FIELD from '@salesforce/schema/Contact.MailingStreet';
import CONTACT_MAILING_CITY_FIELD from '@salesforce/schema/Contact.MailingCity';
import CONTACT_MAILING_STATE_FIELD from '@salesforce/schema/Contact.MailingState';
import CONTACT_MAILING_POSTAL_CODE_FIELD from '@salesforce/schema/Contact.MailingPostalCode';
import CONTACT_ACCOUNT_NAME_FIELD from '@salesforce/schema/Contact.Account.Name';

const VOICE_CALL_FIELDS = [
    RELATED_RECORD_FIELD
];

const CONTACT_FIELDS = [
    CONTACT_NAME_FIELD,
    CONTACT_PHONE_FIELD,
    CONTACT_EMAIL_FIELD,
    CONTACT_MAILING_STREET_FIELD,
    CONTACT_MAILING_CITY_FIELD,
    CONTACT_MAILING_STATE_FIELD,
    CONTACT_MAILING_POSTAL_CODE_FIELD,
    CONTACT_ACCOUNT_NAME_FIELD
];

export default class CoachforceContactCard extends LightningElement {
    @api recordId;

    contactId;
    contactRecord;
    voiceCallRecord;
    errorMessage;
    isLoading = true;

    @wire(getRecord, { recordId: '$recordId', fields: VOICE_CALL_FIELDS })
    wiredVoiceCall({ error, data }) {
        if (data) {
            this.voiceCallRecord = data;
            this.contactId = getFieldValue(data, RELATED_RECORD_FIELD);
            this.errorMessage = null;

            if (!this.contactId) {
                this.isLoading = false;
                this.errorMessage = 'No related contact is associated with this call.';
            }
        } else if (error) {
            this.errorMessage = 'Unable to load the call record.';
            this.isLoading = false;
        }
    }

    @wire(getRecord, { recordId: '$contactId', fields: CONTACT_FIELDS })
    wiredContact({ error, data }) {
        if (data) {
            this.contactRecord = data;
            this.errorMessage = null;
            this.isLoading = false;
        } else if (error && this.contactId) {
            this.errorMessage = 'Unable to load the related contact.';
            this.isLoading = false;
        }
    }

    get contactLoaded() {
        return !!this.contactRecord;
    }

    get contactName() {
        return getFieldValue(this.contactRecord, CONTACT_NAME_FIELD) || '';
    }

    get phone() {
        return getFieldValue(this.contactRecord, CONTACT_PHONE_FIELD) || '';
    }

    get email() {
        return getFieldValue(this.contactRecord, CONTACT_EMAIL_FIELD) || '';
    }

    get accountName() {
        return getFieldValue(this.contactRecord, CONTACT_ACCOUNT_NAME_FIELD) || '';
    }

    get emailHref() {
        return this.email ? `mailto:${this.email}` : null;
    }

    get phoneHref() {
        return this.phone ? `tel:${this.phone}` : null;
    }

    get hasPatientStatus() {
        return false;
    }

    get patientStatusLabel() {
        return '';
    }

    get patientStatusClass() {
        return 'status-pill status-pill_default';
    }

    get locationLine() {
        const city = getFieldValue(this.contactRecord, CONTACT_MAILING_CITY_FIELD);
        const state = getFieldValue(this.contactRecord, CONTACT_MAILING_STATE_FIELD);

        if (city && state) {
            return `${city}, ${state}`;
        }
        return city || state || '';
    }

    get addressLine() {
        const street = getFieldValue(this.contactRecord, CONTACT_MAILING_STREET_FIELD);
        const city = getFieldValue(this.contactRecord, CONTACT_MAILING_CITY_FIELD);
        const state = getFieldValue(this.contactRecord, CONTACT_MAILING_STATE_FIELD);
        const postalCode = getFieldValue(this.contactRecord, CONTACT_MAILING_POSTAL_CODE_FIELD);

        const locality = [city, state].filter(Boolean).join(', ');
        const line2 = [locality, postalCode].filter(Boolean).join(' ');

        if (street && line2) {
            return `${street}, ${line2}`;
        }
        return street || line2 || '';
    }

    get initials() {
        const name = this.contactName;
        if (!name) {
            return '?';
        }

        const parts = name.trim().split(/\s+/);
        if (parts.length === 1) {
            return parts[0].charAt(0).toUpperCase();
        }

        return (
            parts[0].charAt(0) +
            parts[parts.length - 1].charAt(0)
        ).toUpperCase();
    }
}