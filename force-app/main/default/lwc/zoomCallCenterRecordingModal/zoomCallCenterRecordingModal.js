import { LightningElement, wire, api } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { getFields } from "./zoomCallCenterRecordingModalHelper";
import getEngagementRecording from "@salesforce/apex/ZoomCallCenterRecordingService.getEngagementRecording";

const fields = getFields();

export default class ZoomCallCenterRecordingModal extends LightningElement {
    @api recordId;

    error;
    queriedFields = {};
    queriedData = {};
    transformedTranscript;
    downloadCSVDisable = false;
    downloadCVS = false;
    isRecordingData = true;

    @wire(getRecord, { recordId: "$recordId", fields })
    wiredPhoneCallInfo({ error, data }) {
        if (data?.fields) {
            this.queriedFields = data?.fields;
        } else {
            this.error = error;
        }
    }

    @wire(getEngagementRecording, { callId: "$callId", recordId: "$recordId" })
    wiredTranscription({ error, data }) {
        console.log('data',data)
        if (data) {
            this.queriedData = data;
            this.transformTranscript(data);
            this.isRecordingData = true;

        } else {
            console.error('ZoomCallCenterRecordingModal ERROR:', error);
            this.error = error;
        }
    }

    get callId() {
        return this.queriedFields?.Call_Id__c?.value;
    }
    get recordingId() {
        return this.queriedFields?.recording_Id__c?.value;
    }
    get callerName() {
        return this.queriedFields?.Name?.value;
    }
    get callDate() {
        return this.queriedFields?.Call_Date_Time__c?.displayValue;
    }
    get isRecordingData(){
         return this.queriedData?.message === 'The recording transcript does not exist.' ? false : true;
    }

    transformTranscript(text) {
        const lines = text.split('\n');
        let transcriptData = [];
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line.match(/^\d+$/)) {
            } else if (line.match(/^\d{2}:\d{2}:\d{2}\.\d{3}\s+-->\s+\d{2}:\d{2}:\d{2}\.\d{3}$/)) {
                transcriptData.push({ timeline: line.trim() });
            } else if (line.startsWith('+') || line.includes(this.callerName)) { 
                // TODO: This is a hack to get the caller name to show up in the transcript. Need to fix this.
                line.split(':');
                const speaker = line.split(':')[0];
                const content = line.split(':')[1];
                transcriptData.push({ speaker: speaker, content: content });
            }
        }
        this.downloadCVS = true;
        this.transformedTranscript = transcriptData;
    }

    handleCSVDownload() {
        this.downloadCSVDisable = true;
        let csv = "Speaker,Text\n";
        this.transformedTranscript.forEach((line) => {
            if (line.speaker) {
                csv += `"${line.speaker}","${line.content}"\n`;
            }
        });
        let downloadLink = document.createElement("a");
        downloadLink.href = "data:text/csv;charset=utf-8," + encodeURIComponent(csv);
        downloadLink.download = `transcription ${this.callerName} ${this.callDate}.csv`;
        document.body.appendChild(downloadLink);
        downloadLink.click();
        document.body.removeChild(downloadLink);
    }
}