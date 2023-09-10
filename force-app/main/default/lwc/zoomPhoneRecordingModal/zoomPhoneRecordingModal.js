import { LightningElement, wire, api } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { getFields } from "./zoomPhoneRecordingModalHelper";
import getPhoneCallRecording from "@salesforce/apex/ZoomPhoneCallRecordingService.getPhoneCallRecording";

const fields = getFields();

export default class ZoomPhoneRecordingModal extends LightningElement {
    @api recordId;

    timer = null;
    _callId;
    recordTypeId;
    isDataLoaded = false;
    isError = false;

    recordingUrl;
    queriedFields = {};
    requestMessage;
    error;
    noRecordingMessage = 'No recording found for this call.';

    @wire(getRecord, { recordId: "$recordId", fields })
    wiredPhoneCallInfo({ error, data }) {
        console.log('data:', data);
        if (data?.fields) {
            this.queriedFields = data?.fields;
            this.recordTypeId = data?.recordTypeId;

            this.timer = setTimeout(() => {
                this.getCallRecording();
            }, 500);
        } else {
            this.error = error;
        }
    }

    get callId() {
        this._callId =  this.queriedFields?.Call_Id__c?.value;
        return this._callId;
    }

    get isRecorded(){
        return this.queriedFields?.has_recording__c?.value;
    }

    async getCallRecording() {
        const responseData = await getPhoneCallRecording({ callId: this.callId, recordId: this.recordId});
        if(responseData?.status_code === 200){
            this.recordingUrl = responseData?.url;
            this.isDataLoaded = true;
        } else if(responseData?.status_code !== 200){
            this.requestMessage = responseData?.status;
            this.isDataLoaded = false;
            this.isError = true;
        }
    }
}