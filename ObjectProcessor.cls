public class ObjectProcessor {

    public static void processObject(String strApiObject, String strRecordId) {
        String fieldList = '';
        String variableName = strApiObject.replace('ACC_', '');
        variableName = 'obj' + variableName.replace('__c', '');
        String code = strApiObject + ' ' + variableName + ' = new ' + strApiObject + '();\n';

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(strApiObject).getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldDescription;

        for (Schema.SObjectField field : fieldMap.values()) {
            fieldDescription = field.getDescribe();
            if (fieldDescription.isCreateable())
                fieldList += fieldDescription.getName() + ',';
        }
        fieldList = fieldList.removeEnd(',');

        List<SObject> sObjectsList = Database.Query('SELECT ' + fieldList + ' FROM ' + strApiObject + ' WHERE Id = \'' + strRecordId + '\'');
        SObject customObject;
        Set<String> stringDataTypesSet = new Set<String>();
        stringDataTypesSet.add('PICKLIST');
        stringDataTypesSet.add('TEXTAREA');
        stringDataTypesSet.add('REFERENCE');
        stringDataTypesSet.add('STRING');
        stringDataTypesSet.add('EMAIL');
        stringDataTypesSet.add('PHONE');
        stringDataTypesSet.add('MULTIPICKLIST');
        stringDataTypesSet.add('URL');

        if (!sObjectsList.isEmpty()) {
            customObject = sObjectsList.get(0);
            for (Schema.SObjectField field : fieldMap.values()) {
                fieldDescription = field.getDescribe();
                if (fieldDescription.isCreateable() && customObject.get(fieldDescription.getName()) != null) {
                    if (('' + fieldDescription.getType()) != 'DATE' && ('' + fieldDescription.getType()) != 'DATETIME') {
                        if (stringDataTypesSet.contains('' + fieldDescription.getType()))
                            code += variableName + '.' + fieldDescription.getName() + ' = \'' + customObject.get(fieldDescription.getName()) + '\';\n';
                        else
                            code += variableName + '.' + fieldDescription.getName() + ' = ' + customObject.get(fieldDescription.getName()) + ';\n';
                    } else if (('' + fieldDescription.getType()) == 'DATE') {
                        code += variableName + '.' + fieldDescription.getName() + ' = System.today();\n';
                    } else {
                        code += variableName + '.' + fieldDescription.getName() + ' = System.now();\n';
                    }
                }
            }
        }

        System.debug('-->' + code);
    }
}
