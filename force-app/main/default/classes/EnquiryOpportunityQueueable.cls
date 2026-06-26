public class EnquiryOpportunityQueueable implements Queueable {

	 private List<Enquiry__c> enquiryList;

    public EnquiryOpportunityQueueable(List<Enquiry__c> enquiryList) {
        this.enquiryList = enquiryList;
    }

    public void execute(QueueableContext context) {
        EnquiryObject.createOpportunities(enquiryList);
    }
}