public class EventDailyNotificationSchedule implements Schedulable {

    public void execute(SchedulableContext sc){
        EventDailyNotificationBatch batch = new EventDailyNotificationBatch();
        Database.executeBatch(batch,50);
    }
    
}