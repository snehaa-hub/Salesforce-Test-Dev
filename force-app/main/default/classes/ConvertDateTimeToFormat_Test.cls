@isTest
public class ConvertDateTimeToFormat_Test {
    @isTest static void convertDateTimeToFormatTestMethod(){
        ConvertDateTimeToFormat.Request req = new ConvertDateTimeToFormat.Request();
        req.value = System.now();
        req.format = 'yyyy/MM/dd hh:mm:ss';
        
        String formattedDate = (System.now()).format('yyyy/MM/dd hh:mm:ss');
        List<ConvertDateTimeToFormat.Response> responseList = ConvertDateTimeToFormat.execute(new List<ConvertDateTimeToFormat.Request>{req});
        Assert.areEqual(formattedDate, responseList[0].formatedDateTime, 'message');
    }
}