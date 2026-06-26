global class ScheduleCreatePersonAccountsBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        CreatePersonAccountsBatch batch = new CreatePersonAccountsBatch();
        Database.executeBatch(batch, 50); // Adjust batch size as needed
    }
}