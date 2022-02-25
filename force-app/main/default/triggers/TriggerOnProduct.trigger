trigger TriggerOnProduct on Product2 (before insert) 
{
    TriggerOnProductHandler handler = new TriggerOnProductHandler(Trigger.New,Trigger.OldMap);
	if(Trigger.IsInsert)
    {
        if(Trigger.isBefore)
        {
            handler.beforeInsert();
        }
    }
}