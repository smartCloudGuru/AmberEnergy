import { getRecord, updateRecord } from "lightning/uiRecordApi";
import CallResolution from '@salesforce/schema/VoiceCall.CallResolution'; 
import Description from '@salesforce/schema/VoiceCall.Description'; 
import { LightningElement, api, track, wire } from 'lwc';

export default class pciPalVoiceFrame extends LightningElement {
    @api redirectUrl; // URL passed from the Flow
    @api participantId; // Participant ID passed from the Flow
    @api participantType; // Participant Type from the Flow
    @api acessToken; // PCI Pal Authorisation Token
    @api refreshToken; // PCI Pall Authorisation Refresh Token
    @api voiceCallID; // PCI Pall Authorisation Refresh Token
    @track isTelephonyActionControlsDisabled = true;
    telephonyEventListener; 
    
 constructor() {
        super();
        this.telephonyEventListener = this.onTelephonyEvent.bind(this);
    }

    get voiceToolkit() {
        return this.template.querySelector("lightning-service-cloud-voice-toolkit-api");
    }

    async onSecureRecording() {
        this.subscribeToVoiceToolkit();
        await this.onAddParticipant(); 
        this.launchPCIPalControlPanel();
        this.updateCallDetails();
    }

    renderedCallback() {
        // Subscribe if not already subscribed
        if (!this.telephonyEventListener) {
            this.subscribeToVoiceToolkit();
        }
    }

    subscribeToVoiceToolkit() {
        const toolkitApi = this.getToolkitApi();
        if (toolkitApi) {
            toolkitApi.addEventListener("participantadded", this.telephonyEventListener);
            console.log("Subscribed to participantadded event.");
        } else {
            console.warn("Toolkit API not available.");
        }
    }

    unsubscribeFromVoiceToolkit() {
        const toolkitApi = this.getToolkitApi();
        if (toolkitApi) {
            toolkitApi.removeEventListener("participantadded", this.telephonyEventListener);
        }
    }

    onTelephonyEvent(event) {
        console.log("Telephony event received:", event); // Log the event to check its details
        if (event.type === "participantadded") {
                console.log("Participant added successfully.");
                const toolkitApi = this.getToolkitApi();
                //toolkitApi.merge();   // Merge the participant
                toolkitApi.endCall(); // End the call after merging
        } else {
            console.warn("Unexpected event type:", event.type); // Log unexpected events
        }
    }

    onAddParticipant() {
        const toolkitApi = this.getToolkitApi();
        if (toolkitApi) {
            toolkitApi.addParticipant(this.participantType, this.participantId, false);
            console.log(`Adding participant: ${this.participantId} of type: ${this.participantType}`);
        } else {
            console.warn("Toolkit API not available for adding participant.");
        }
    }

    getToolkitApi() {
        return this.template.querySelector("lightning-service-cloud-voice-toolkit-api");
    }

    // Remember to unsubscribe when the component is destroyed
    disconnectedCallback() {
        this.unsubscribeFromVoiceToolkit();
    }

    launchPCIPalControlPanel() {
        if (this.redirectUrl) {
            const newWindow = window.open('', 'submissionResultWindow', 'width=800,height=600');

            if (!newWindow) {
                console.error('Pop-up was blocked. Please allow pop-ups for this site.');
                return;
            }

            const form = document.createElement('form');
            form.action = this.redirectUrl;
            form.method = 'POST';
            form.target = 'submissionResultWindow';

            const bearerTokenInput = document.createElement('input');
            bearerTokenInput.type = 'hidden';
            bearerTokenInput.name = 'X-BEARER-TOKEN';
            bearerTokenInput.value = this.acessToken;

            const refreshTokenInput = document.createElement('input');
            refreshTokenInput.type = 'hidden';
            refreshTokenInput.name = 'X-REFRESH-TOKEN';
            refreshTokenInput.value = this.refreshToken;

            form.appendChild(bearerTokenInput);
            form.appendChild(refreshTokenInput);

            document.body.appendChild(form);
            form.submit();
            document.body.removeChild(form);
        }
    }

    updateCallDetails() {

        // Prepare the fields for the update
        const fields = {};

        fields.Id = this.voiceCallID; 
        fields[Description.fieldApiName] = 'Auto Resolved - Activated the PCI Pal payment secure flow to take payment.'; 
        fields[CallResolution.fieldApiName] = 'Resolved'; 

        const recordInput = { fields };

        // Delay the execution by 20 seconds

        // We auto answer calls and we need to make sure the resident has been 
        // transferred to PCI Pal and come back at a higher priority before 
        // we put the agent to available otherwise they will answer another
        // resident call.

        setTimeout(() => {
            // Update the record
            updateRecord(recordInput)
                .then(() => {
                    console.log('CallResolution updated to Resolved and CallDescription set to Complete successfully');
                    // Optionally, refresh the record or handle post-update logic
                })
                .catch(error => {
                    console.error('Error updating CallResolution and CallDescription:', error);
                });

        }, 15000);
    }
}