public with sharing class TriggerOnProductHandler 
{
    private List<Product2> newProducts;
    private Map<Id,Product2> oldProductsMap;
    public TriggerOnProductHandler(List<Product2> newProducts, Map<Id,Product2> oldProductsMap)
    {
        this.newProducts = newProducts;
        this.oldProductsMap = oldProductsMap;
    }
    public void beforeInsert()
    {
        TriggerOnProductService.checkAndUpdateProductCode(newProducts, oldProductsMap);
    }
}