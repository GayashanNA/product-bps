set serveroutput on
CREATE OR REPLACE PROCEDURE cleanInstance(inst_state NUMBER, lastActive TIMESTAMP)
IS
   CURSOR test_cus IS SELECT ID FROM ODE_PROCESS_INSTANCE WHERE INSTANCE_STATE = inst_state AND LAST_ACTIVE_TIME < lastActive;
BEGIN
FOR i IN test_cus
LOOP
dbms_output.put_line (' Start deleting instance data with instance id ' || i.ID);
DELETE FROM ODE_EVENT WHERE INSTANCE_ID = i.ID;
DELETE FROM ODE_CORSET_PROP WHERE CORRSET_ID IN (SELECT cs.CORRELATION_SET_ID FROM ODE_CORRELATION_SET cs WHERE cs.SCOPE_ID IN (SELECT os.SCOPE_ID FROM ODE_SCOPE os WHERE os.PROCESS_INSTANCE_ID = i.ID));
DELETE FROM ODE_CORRELATION_SET WHERE SCOPE_ID IN (SELECT os.SCOPE_ID FROM ODE_SCOPE os WHERE os.PROCESS_INSTANCE_ID = i.ID);
DELETE FROM ODE_PARTNER_LINK WHERE SCOPE_ID IN (SELECT os.SCOPE_ID FROM ODE_SCOPE os WHERE os.PROCESS_INSTANCE_ID = i.ID);
DELETE FROM ODE_XML_DATA_PROP WHERE XML_DATA_ID IN (SELECT xd.XML_DATA_ID FROM ODE_XML_DATA xd WHERE xd.SCOPE_ID IN (SELECT os.SCOPE_ID FROM ODE_SCOPE os WHERE os.PROCESS_INSTANCE_ID = i.ID));
DELETE FROM ODE_XML_DATA WHERE SCOPE_ID IN (SELECT os.SCOPE_ID FROM ODE_SCOPE os WHERE os.PROCESS_INSTANCE_ID = i.ID);
DELETE FROM ODE_SCOPE WHERE PROCESS_INSTANCE_ID = i.ID;
DELETE FROM ODE_MEX_PROP WHERE MEX_ID IN (SELECT mex.MESSAGE_EXCHANGE_ID FROM ODE_MESSAGE_EXCHANGE mex WHERE mex.PROCESS_INSTANCE_ID = i.ID);
DELETE FROM ODE_MESSAGE WHERE MESSAGE_EXCHANGE_ID IN (SELECT mex.MESSAGE_EXCHANGE_ID FROM ODE_MESSAGE_EXCHANGE mex WHERE mex.PROCESS_INSTANCE_ID = i.ID);
DELETE FROM ODE_MESSAGE_EXCHANGE WHERE PROCESS_INSTANCE_ID = i.ID;
DELETE FROM ODE_MESSAGE_ROUTE WHERE PROCESS_INSTANCE_ID = i.ID;
DELETE FROM ODE_PROCESS_INSTANCE WHERE ID = i.ID;
COMMIT;
dbms_output.put_line (' End deleting instance data with instance id ' || i.ID);
END LOOP;
END;
/

SET AUTOCOMMIT OFF;
VARIABLE INST_STATE NUMBER;

BEGIN 
:INST_STATE := 30;
END;
/

DECLARE
    LAST_ACTIVE TIMESTAMP;
BEGIN
  SELECT (SYSTIMESTAMP - 2) INTO LAST_ACTIVE FROM DUAL;
  dbms_output.put_line (' Starting cleanInstance procedure ');
  cleanInstance(:INST_STATE, LAST_ACTIVE);
  dbms_output.put_line (' Ending cleanInstance procedure '); 
END;
/
SET AUTOCOMMIT ON;
