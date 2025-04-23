import { LightningElement, api, track, wire } from 'lwc';

export default class PciPalDigitalFrame extends LightningElement 
{
    @api redirectUrl; // URL passed from the Flow
    @api acessToken; // PCI Pal Authorisation Token
    @api refreshToken; // PCI Pall Authorisation Refresh Token

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
}