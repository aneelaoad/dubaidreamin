import { LightningElement,api,  wire, track } from "lwc";
import getSpeakers from "@salesforce/apex/SpeakerController.getSpeakers";
import { subscribe, MessageContext } from "lightning/messageService";
import SCROLL_MESSAGE from '@salesforce/messageChannel/ScrollMessageChannel__c';
import EVENT_ID_LMS from '@salesforce/messageChannel/EventIDMessageChannel__c';
import IMAGES from '@salesforce/resourceUrl/IMAGES'
import SpeakerLabel from '@salesforce/label/c.Speaker_Label';
import AllSpeakersLabel from '@salesforce/label/c.All_Speakers_Label';
import ButtonLabel from '@salesforce/label/c.Button_View_Label';
import getDubaiDreaminEventId from '@salesforce/apex/EventController.getDubaiDreaminEventId';

export default class speakerSection extends LightningElement {
  subscription = null;
  scrlMsg;
  @track speakerInformation;
  showAllSpeakers = false;
  @track allspeakerInformation = [];
  @track threespeakerInformation;
  selectedEventId;
  showModal = false;
  speakerLabel = SpeakerLabel;
  allSpeakersLabel = AllSpeakersLabel;
  buttonLabel = ButtonLabel;
  speakerId;
  profilePlaceholder;
  speakerModalDetails;
  speakerName;
  speakerDescription;
  speakerTitle;
  speakerEmail;
  speakerPhone;
  speakerImage;
  speakerSocialMedia;



    @wire(getDubaiDreaminEventId)
    wiredEventId({ error, data }) {
      console.log('speaker data'+data);
    if (data) {

        this.selectedEventId=data;

        // console.log('vlaid enet id:'+data);
       
    } else if (error) {
        console.error('getDubaiDreaminEventId Error:', error);
    }
    }
  openModal(event) {
    this.showModal = true;
    this.speakerId = event.target.dataset.speakerid
   
    this.speakerModalDetails = this.speakerInformation.find(speaker => speaker.speakerName === this.speakerId)

    this.speakerName = this.speakerModalDetails.speakerName;
    this.speakerDescription = this.speakerModalDetails.speakerInformation;
    this.speakerTitle = this.speakerModalDetails.speakerTitle;
    this.speakerEmail = this.speakerModalDetails.speakerEmail;
    this.speakerPhone = this.speakerModalDetails.speakerContactNumber;
    this.speakerImage = this.speakerModalDetails.speakerImage;
    this.speakerSocialMedia = this.speakerModalDetails.speakerSocialMedia;
    document.body.style.overflow = 'hidden';

  }

  closeModal() {
    this.showModal = false;
    document.body.style.overflow = 'auto';

  }

  @wire(MessageContext) messageContext;


  subscribeToMessageChannel() {
    this.subscription = subscribe(this.messageContext, EVENT_ID_LMS, (eventMessage) => this.handleMessage(eventMessage));
    this.scrlMsg = subscribe(this.messageContext, SCROLL_MESSAGE, (message) => this.handleScroll(message));
  }

@wire(getSpeakers, { eventId: '$selectedEventId' })
wiredData({ error, data }) {
  if (data) {
 this.speakerInformation = data;
  //  this.threespeakerInformation = this.speakerInformation.slice(0, 3);  } else if (error) {
   this.threespeakerInformation = this.speakerInformation;console.log('datalist:', data);  } else if (error) {
     console.error('Error:', error);
  }
}
  handleMessage(eventMessage) {
    this.selectedEventId = eventMessage.eventId;
   
    getSpeakers({ eventId: this.selectedEventId })
      .then(data => {
        this.speakerInformation = data;
        // this.threespeakerInformation = this.speakerInformation.slice(0, 3);
        this.threespeakerInformation = this.speakerInformation;

      });
  }

  handleScroll(message) {
    const scrollSection = message.section;

    if (scrollSection === 'Speakers') {
   
      this.template.querySelector('.sectionSpeaker').scrollIntoView({ behavior: 'smooth' });

    }
  }
  handleViewAllClick() {
    this.showAllSpeakers = true;
    this.allspeakerInformation = this.speakerInformation;
    document.body.style.overflow = 'hidden';

  }
  handleCloseModal() {
    this.showAllSpeakers = false;
    document.body.style.overflow = 'auto';

  }
  connectedCallback() {
    this.subscribeToMessageChannel();
    // this.profilePlaceholder = IMAGES + '/profile' + '.png';
    this.profilePlaceholder = IMAGES + '/email_logo.png';
    // this.profilePlaceholder = 'https://i.imgur.com/aK4EdrM.png';
  }
























}