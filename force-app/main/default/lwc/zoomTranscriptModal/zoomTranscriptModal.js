import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { getFields } from "./ZoomTranscriptModalHelper";
import getCallTranscription from "@salesforce/apex/ZoomCallTranscriptionController.getCallTranscription";

const fields = getFields();

export default class ZoomTranscriptModal extends LightningElement {
    @api recordId;

    error;
    _isLoading = false;
    queriedFields = {};
    queriedData = {};
    downloadCVS = false;
    callLog = null;
    downloadCSVDisable = false;
    emptyResponse = 'This phone call does not have a conversation record. Please check the value of the "Has Recording" field.';

    @wire(getRecord, { recordId: "$recordId", fields })
    wiredPhoneCallInfo({ error, data }) {
        if (data?.fields) {
            this.queriedFields = data?.fields;
        } else {
            this.error = error;
        }
    }
    @wire(getCallTranscription, { recordingId: "$recordingId" })
    wiredTranscription({ error, data }) {
        console.log('data:', data);
        if (data?.timeline) {
            this._isLoading = true;
            this.queriedData = data?.timeline;
            this.parseCallLogData();
            console.log('====================this.queriedData:', this.queriedData);
        } else {
            console.log('====================error:', error);
            this.error = error;
        }
    }

    //================================GETTERS===========================================
    //==================================================================================
    get isLoading() {
        return this._isLoading;
    }
    get callerName() {
        return this.queriedFields?.Name?.value;
    }
    get callDate() {
        return this.queriedFields?.Call_Date_Time__c?.displayValue;
    }
    get recordingId() {
        return this.queriedFields?.recording_Id__c?.value;
    }
    get recordingAvailable() {
        return this.recordingId === null ? true : false;
    }

    //=================================CALLBACK=========================================
    //==================================================================================
    connectedCallback() {}
    disconnectedCallback() {}
    errorCallback(error, stack) {
        console.error("ZoomTranscriptModal: errorCallback", error, stack);
    }

    //==========================================FUNCTIONS==============================
    //=================================================================================
    parseCallLogData() {
        this.downloadCVS = true;
        this.callLog = this.queriedData.map((e) => {
            let users = e.users.map((u) => u.username).join(",");
            return {
                speaker: users,
                text: e.text,
                ts: e.ts
            };
        });
        console.log('====================this.callLog:', this.callLog);
    }

    //==========================================HANDLERS===============================
    //=================================================================================
    handleCSVDownload() {
        this.downloadCSVDisable = true;
        let csv = "Speaker,Text,ts\n";
        this.queriedData.forEach((e) => {
            csv += `"${e.users.map((u) => u.username)}","${e.text}", "${e.ts}"\n`;
        });
        let downloadLink = document.createElement("a");
        downloadLink.href = "data:text/csv;charset=utf-8," + encodeURIComponent(csv);
        downloadLink.download = `transcription ${this.callerName} ${this.callDate}.csv`;
        document.body.appendChild(downloadLink);
        downloadLink.click();
        document.body.removeChild(downloadLink);
    }
}