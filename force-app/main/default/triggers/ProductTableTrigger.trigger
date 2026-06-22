trigger ProductTableTrigger on ProductTable__c (before insert, before update) {
    if (Trigger.isBefore) {
        ProductTableTriggerHelper.handleBefore(
            Trigger.new,
            Trigger.isInsert
        );
    }
}
