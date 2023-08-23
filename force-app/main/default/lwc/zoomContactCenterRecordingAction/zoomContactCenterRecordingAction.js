import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';


export default class ZoomContactCenterRecordingAction extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: ['Zoom_Phone_Call_Info__c.has_recording__c'] })
    objectData;

    get isButtonDisabled() {
        const fieldValue = getFieldValue(this.objectData.data, 'Zoom_Phone_Call_Info__c.has_recording__c');
        // Replace 'DesiredValue' with the condition you want to check
        return fieldValue === false;
    }

    handleButtonClick() {
        // Your button click logic
    }
}