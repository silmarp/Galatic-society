set serveroutput on;
BEGIN
   -- Drop all tables
   FOR rec IN (SELECT table_name FROM user_tables) LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP TABLE ' || rec.table_name || ' CASCADE CONSTRAINTS';
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Failed to drop table: ' || rec.table_name || ' - ' || SQLERRM);
      END;
   END LOOP;

   -- Drop all indexes
   FOR rec IN (SELECT index_name FROM user_indexes WHERE index_type = 'NORMAL') LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP INDEX ' || rec.index_name;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Failed to drop index: ' || rec.index_name || ' - ' || SQLERRM);
      END;
   END LOOP;

   -- Drop all views
   FOR rec IN (SELECT view_name FROM user_views) LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP VIEW ' || rec.view_name;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Failed to drop view: ' || rec.view_name || ' - ' || SQLERRM);
      END;
   END LOOP;

   -- Drop all sequences
   FOR rec IN (SELECT sequence_name FROM user_sequences) LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP SEQUENCE ' || rec.sequence_name;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Failed to drop sequence: ' || rec.sequence_name || ' - ' || SQLERRM);
      END;
   END LOOP;

   -- Drop all procedures
   FOR rec IN (SELECT object_name FROM user_procedures WHERE object_type = 'PROCEDURE') LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP PROCEDURE ' || rec.object_name;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Failed to drop procedure: ' || rec.object_name || ' - ' || SQLERRM);
      END;
   END LOOP;

   -- Drop all functions
   FOR rec IN (SELECT object_name FROM user_procedures WHERE object_type = 'FUNCTION') LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP FUNCTION ' || rec.object_name;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Failed to drop function: ' || rec.object_name || ' - ' || SQLERRM);
      END;
   END LOOP;

   -- Drop all packages
   FOR rec IN (SELECT object_name FROM user_objects WHERE object_type = 'PACKAGE') LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP PACKAGE ' || rec.object_name;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Failed to drop package: ' || rec.object_name || ' - ' || SQLERRM);
      END;
   END LOOP;

   -- Drop all triggers
   FOR rec IN (SELECT trigger_name FROM user_triggers) LOOP
      BEGIN
         EXECUTE IMMEDIATE 'DROP TRIGGER ' || rec.trigger_name;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Failed to drop trigger: ' || rec.trigger_name || ' - ' || SQLERRM);
      END;
   END LOOP;
END;
/