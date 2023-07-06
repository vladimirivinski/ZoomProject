import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import getObjectRecordTypes from "@salesforce/apex/DependentListHandler.getObjectRecordTypes";

export default class DependentListChecker extends LightningElement {

    @track objectNameToGetFields;
    @track recordTypeOptions = [];
    @track firstStageFields = [];
    @track secondStageFields = [];
    @track thirdStageFields = [];
    
    selectedObjectValue;
    selectedRecordTypeName;
    selectedRecordTypeId;
    selectedFieldFirstStage;
    selectedFieldSecondStage;
    selectedFieldThirdStage;

    objectData = {};
    _fieldApiName;

    @wire(getObjectInfo, { objectApiName: '$objectNameToGetFields' })
    getObjectInfo({ error, data }) {
        if (data) {
            console.log('data:', data);
            this.objectData = data;
            this.firstStageFields = Object.keys(data.dependentFields).map( val => ({label: val, value: val}))
            this.recordTypeOptions = Object.entries(data.recordTypeInfos).map(([id, name]) => ({label: name.name, value: id}));
        }else if (error) {
            console.error('Error while getting fields');
            this.handleRefresh();
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$this.selectedRecordTypeId', fieldApiName: '$fieldApiName' })
    getPicklistValues({ error, data }) {
        if(data){
            debugger
            console.log('VALUES data:', data);
        }else if (error) {
            console.error('Error while picklist values');
            this.handleRefresh();
        }
    }

    
    
    //=========================================================================================
    //================================GETTERS==================================================

    get options() {
        return [
            { label: 'Account', value: 'Account' },
            { label: 'Case',    value: 'Case' },
            { label: 'Lead',    value: 'Lead' },
        ];
    }

    get isControlingField(){
        return this.selectedFieldFirstStage != null ? true : false;
    }

    get isControlingFieldSecondStage(){
        return this.thirdStageFields.length ? true : false;
    }

    get recordTypes(){
        return this.objectData.recordTypeInfos;
    }

    get fieldApiName(){
        if(this.selectedObjectValue !== null && this.selectedFieldFirstStage !== null){
            this._fieldApiName = this.selectedObjectValue+'.'+ this.selectedFieldFirstStage
        }    
        return this._fieldApiName;
    }


    //=================================CALLBACK=========================================
    //==================================================================================
    connectedCallback() {}
    disconnectedCallback() {}
    errorCallback(error, stack) {
        console.error("DependentListChecker: errorCallback", error, stack);
    }


    //=========================================================================================
    //================================FUNCTIONS================================================

    populateSecondStageFields(firstStageVal){
        this.secondStageFields = Object.keys(
            this.objectData.dependentFields[firstStageVal])
                .map( val => ({value: val, label: val}));
    }

    populateThirdStageFields(secondVal){
        this.thirdStageFields = Object.keys(
            this.objectData.dependentFields[this.selectedFieldFirstStage][secondVal])
                .map( val => ({value: val, label: val}));
    }

    // async sendQuery(){
    //     const payload = {
    //         objectName: this.selectedObjectValue,
    //         firstField: this.selectedFieldFirstStage,
    //         secondField: this.selectedFieldSecondStage,
    //         thirdField: this.selectedFieldThirdStage
    //     }
    //     try{
    //         const resultFields = await this.convertObjectFieldString(payload);
    //     } catch (error) {
    //         console.error("query ERROR:", error);
    //         return [];
    //     }
    // }
    
    //=========================================================================================
    //================================HANDLERS=================================================

    handleChangeObject(event) {
        this.handleRefresh();
        this.selectedObjectValue = event.detail.value;
        this.objectNameToGetFields = this.selectedObjectValue;
    }
    handleRecordTypeChange(event){
        this.selectedRecordTypeName = event.detail.label;
        this.selectedRecordTypeId = event.detail.value;
        console.log('this.selectedRecordTypeName:', this.selectedRecordTypeName);
        console.log('this.selectedRecordTypeId:', this.selectedRecordTypeId);
    }
    handleChangeFirstStageField(event) {
        this.selectedFieldFirstStage = event.detail.value;
        this.populateSecondStageFields(this.selectedFieldFirstStage);
    }
    handleChangeSecondStageField(event) {
        this.selectedFieldSecondStage = event.detail.value;
        this.populateThirdStageFields(this.selectedFieldSecondStage);
        
    }
    handleChangeThirdStageField(event) {
        this.selectedFieldThirdStage = event.detail.value;
    }
    handleRefresh(){
        this.selectedObjectValue = null;
        this.selectedFieldFirstStage = null;
        this.selectedFieldSecondStage = null;
        this.selectedFieldThirdStage = null;
        this.firstStageFields = []
        this.secondStageFields = [];
        this.thirdStageFields = [];
        this.recordTypeOptions = [];
    }

    async submitHandlerButton(){

    }
}