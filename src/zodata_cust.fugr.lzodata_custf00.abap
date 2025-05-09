*---------------------------------------------------------------------*
*    view related FORM routines
*---------------------------------------------------------------------*
*...processing: ZODATA_V_ACTIONS................................*
FORM GET_DATA_ZODATA_V_ACTIONS.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZODATA_ACTIONS WHERE
(VIM_WHERETAB) .
    CLEAR ZODATA_V_ACTIONS .
ZODATA_V_ACTIONS-MANDT =
ZODATA_ACTIONS-MANDT .
ZODATA_V_ACTIONS-NAMESPACE =
ZODATA_ACTIONS-NAMESPACE .
ZODATA_V_ACTIONS-ENTITY =
ZODATA_ACTIONS-ENTITY .
ZODATA_V_ACTIONS-ACTION_NAME =
ZODATA_ACTIONS-ACTION_NAME .
ZODATA_V_ACTIONS-RETURNING_ENTITY =
ZODATA_ACTIONS-RETURNING_ENTITY .
ZODATA_V_ACTIONS-HTTP_METHOD =
ZODATA_ACTIONS-HTTP_METHOD .
ZODATA_V_ACTIONS-STRUCTURE_NAME =
ZODATA_ACTIONS-STRUCTURE_NAME .
<VIM_TOTAL_STRUC> = ZODATA_V_ACTIONS.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZODATA_V_ACTIONS .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZODATA_V_ACTIONS.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZODATA_V_ACTIONS-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_ACTIONS WHERE
  NAMESPACE = ZODATA_V_ACTIONS-NAMESPACE AND
  ENTITY = ZODATA_V_ACTIONS-ENTITY AND
  ACTION_NAME = ZODATA_V_ACTIONS-ACTION_NAME .
    IF SY-SUBRC = 0.
    DELETE ZODATA_ACTIONS .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_ACTIONS WHERE
  NAMESPACE = ZODATA_V_ACTIONS-NAMESPACE AND
  ENTITY = ZODATA_V_ACTIONS-ENTITY AND
  ACTION_NAME = ZODATA_V_ACTIONS-ACTION_NAME .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZODATA_ACTIONS.
    ENDIF.
ZODATA_ACTIONS-MANDT =
ZODATA_V_ACTIONS-MANDT .
ZODATA_ACTIONS-NAMESPACE =
ZODATA_V_ACTIONS-NAMESPACE .
ZODATA_ACTIONS-ENTITY =
ZODATA_V_ACTIONS-ENTITY .
ZODATA_ACTIONS-ACTION_NAME =
ZODATA_V_ACTIONS-ACTION_NAME .
ZODATA_ACTIONS-RETURNING_ENTITY =
ZODATA_V_ACTIONS-RETURNING_ENTITY .
ZODATA_ACTIONS-HTTP_METHOD =
ZODATA_V_ACTIONS-HTTP_METHOD .
ZODATA_ACTIONS-STRUCTURE_NAME =
ZODATA_V_ACTIONS-STRUCTURE_NAME .
    IF SY-SUBRC = 0.
    UPDATE ZODATA_ACTIONS ##WARN_OK.
    ELSE.
    INSERT ZODATA_ACTIONS .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZODATA_V_ACTIONS-UPD_FLAG,
STATUS_ZODATA_V_ACTIONS-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZODATA_V_ACTIONS.
  SELECT SINGLE * FROM ZODATA_ACTIONS WHERE
NAMESPACE = ZODATA_V_ACTIONS-NAMESPACE AND
ENTITY = ZODATA_V_ACTIONS-ENTITY AND
ACTION_NAME = ZODATA_V_ACTIONS-ACTION_NAME .
ZODATA_V_ACTIONS-MANDT =
ZODATA_ACTIONS-MANDT .
ZODATA_V_ACTIONS-NAMESPACE =
ZODATA_ACTIONS-NAMESPACE .
ZODATA_V_ACTIONS-ENTITY =
ZODATA_ACTIONS-ENTITY .
ZODATA_V_ACTIONS-ACTION_NAME =
ZODATA_ACTIONS-ACTION_NAME .
ZODATA_V_ACTIONS-RETURNING_ENTITY =
ZODATA_ACTIONS-RETURNING_ENTITY .
ZODATA_V_ACTIONS-HTTP_METHOD =
ZODATA_ACTIONS-HTTP_METHOD .
ZODATA_V_ACTIONS-STRUCTURE_NAME =
ZODATA_ACTIONS-STRUCTURE_NAME .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZODATA_V_ACTIONS USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZODATA_V_ACTIONS-NAMESPACE TO
ZODATA_ACTIONS-NAMESPACE .
MOVE ZODATA_V_ACTIONS-ENTITY TO
ZODATA_ACTIONS-ENTITY .
MOVE ZODATA_V_ACTIONS-ACTION_NAME TO
ZODATA_ACTIONS-ACTION_NAME .
MOVE ZODATA_V_ACTIONS-MANDT TO
ZODATA_ACTIONS-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZODATA_ACTIONS'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZODATA_ACTIONS TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZODATA_ACTIONS'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZODATA_V_ACTPARA................................*
FORM GET_DATA_ZODATA_V_ACTPARA.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZODATA_ACT_PARAM WHERE
(VIM_WHERETAB) .
    CLEAR ZODATA_V_ACTPARA .
ZODATA_V_ACTPARA-MANDT =
ZODATA_ACT_PARAM-MANDT .
ZODATA_V_ACTPARA-NAMESPACE =
ZODATA_ACT_PARAM-NAMESPACE .
ZODATA_V_ACTPARA-ENTITY =
ZODATA_ACT_PARAM-ENTITY .
ZODATA_V_ACTPARA-ACTION_NAME =
ZODATA_ACT_PARAM-ACTION_NAME .
ZODATA_V_ACTPARA-FIELDNAME =
ZODATA_ACT_PARAM-FIELDNAME .
ZODATA_V_ACTPARA-PARAMETER_NAME =
ZODATA_ACT_PARAM-PARAMETER_NAME .
<VIM_TOTAL_STRUC> = ZODATA_V_ACTPARA.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZODATA_V_ACTPARA .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZODATA_V_ACTPARA.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZODATA_V_ACTPARA-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_ACT_PARAM WHERE
  NAMESPACE = ZODATA_V_ACTPARA-NAMESPACE AND
  ENTITY = ZODATA_V_ACTPARA-ENTITY AND
  ACTION_NAME = ZODATA_V_ACTPARA-ACTION_NAME AND
  PARAMETER_NAME = ZODATA_V_ACTPARA-PARAMETER_NAME .
    IF SY-SUBRC = 0.
    DELETE ZODATA_ACT_PARAM .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_ACT_PARAM WHERE
  NAMESPACE = ZODATA_V_ACTPARA-NAMESPACE AND
  ENTITY = ZODATA_V_ACTPARA-ENTITY AND
  ACTION_NAME = ZODATA_V_ACTPARA-ACTION_NAME AND
  PARAMETER_NAME = ZODATA_V_ACTPARA-PARAMETER_NAME .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZODATA_ACT_PARAM.
    ENDIF.
ZODATA_ACT_PARAM-MANDT =
ZODATA_V_ACTPARA-MANDT .
ZODATA_ACT_PARAM-NAMESPACE =
ZODATA_V_ACTPARA-NAMESPACE .
ZODATA_ACT_PARAM-ENTITY =
ZODATA_V_ACTPARA-ENTITY .
ZODATA_ACT_PARAM-ACTION_NAME =
ZODATA_V_ACTPARA-ACTION_NAME .
ZODATA_ACT_PARAM-FIELDNAME =
ZODATA_V_ACTPARA-FIELDNAME .
ZODATA_ACT_PARAM-PARAMETER_NAME =
ZODATA_V_ACTPARA-PARAMETER_NAME .
    IF SY-SUBRC = 0.
    UPDATE ZODATA_ACT_PARAM ##WARN_OK.
    ELSE.
    INSERT ZODATA_ACT_PARAM .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZODATA_V_ACTPARA-UPD_FLAG,
STATUS_ZODATA_V_ACTPARA-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZODATA_V_ACTPARA.
  SELECT SINGLE * FROM ZODATA_ACT_PARAM WHERE
NAMESPACE = ZODATA_V_ACTPARA-NAMESPACE AND
ENTITY = ZODATA_V_ACTPARA-ENTITY AND
ACTION_NAME = ZODATA_V_ACTPARA-ACTION_NAME AND
PARAMETER_NAME = ZODATA_V_ACTPARA-PARAMETER_NAME .
ZODATA_V_ACTPARA-MANDT =
ZODATA_ACT_PARAM-MANDT .
ZODATA_V_ACTPARA-NAMESPACE =
ZODATA_ACT_PARAM-NAMESPACE .
ZODATA_V_ACTPARA-ENTITY =
ZODATA_ACT_PARAM-ENTITY .
ZODATA_V_ACTPARA-ACTION_NAME =
ZODATA_ACT_PARAM-ACTION_NAME .
ZODATA_V_ACTPARA-FIELDNAME =
ZODATA_ACT_PARAM-FIELDNAME .
ZODATA_V_ACTPARA-PARAMETER_NAME =
ZODATA_ACT_PARAM-PARAMETER_NAME .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZODATA_V_ACTPARA USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZODATA_V_ACTPARA-NAMESPACE TO
ZODATA_ACT_PARAM-NAMESPACE .
MOVE ZODATA_V_ACTPARA-ENTITY TO
ZODATA_ACT_PARAM-ENTITY .
MOVE ZODATA_V_ACTPARA-ACTION_NAME TO
ZODATA_ACT_PARAM-ACTION_NAME .
MOVE ZODATA_V_ACTPARA-PARAMETER_NAME TO
ZODATA_ACT_PARAM-PARAMETER_NAME .
MOVE ZODATA_V_ACTPARA-MANDT TO
ZODATA_ACT_PARAM-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZODATA_ACT_PARAM'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZODATA_ACT_PARAM TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZODATA_ACT_PARAM'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZODATA_V_ENTITY.................................*
FORM GET_DATA_ZODATA_V_ENTITY.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZODATA_ENTITY WHERE
(VIM_WHERETAB) .
    CLEAR ZODATA_V_ENTITY .
ZODATA_V_ENTITY-MANDT =
ZODATA_ENTITY-MANDT .
ZODATA_V_ENTITY-NAMESPACE =
ZODATA_ENTITY-NAMESPACE .
ZODATA_V_ENTITY-ENTITY_NAME =
ZODATA_ENTITY-ENTITY_NAME .
ZODATA_V_ENTITY-CLASS_NAME =
ZODATA_ENTITY-CLASS_NAME .
ZODATA_V_ENTITY-STRUCTURE =
ZODATA_ENTITY-STRUCTURE .
ZODATA_V_ENTITY-IS_COMPLEX =
ZODATA_ENTITY-IS_COMPLEX .
ZODATA_V_ENTITY-DEEP_ENTITY_STRUCTURE =
ZODATA_ENTITY-DEEP_ENTITY_STRUCTURE .
ZODATA_V_ENTITY-IS_MEDIA =
ZODATA_ENTITY-IS_MEDIA .
<VIM_TOTAL_STRUC> = ZODATA_V_ENTITY.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZODATA_V_ENTITY .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZODATA_V_ENTITY.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZODATA_V_ENTITY-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_ENTITY WHERE
  NAMESPACE = ZODATA_V_ENTITY-NAMESPACE AND
  ENTITY_NAME = ZODATA_V_ENTITY-ENTITY_NAME .
    IF SY-SUBRC = 0.
    DELETE ZODATA_ENTITY .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_ENTITY WHERE
  NAMESPACE = ZODATA_V_ENTITY-NAMESPACE AND
  ENTITY_NAME = ZODATA_V_ENTITY-ENTITY_NAME .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZODATA_ENTITY.
    ENDIF.
ZODATA_ENTITY-MANDT =
ZODATA_V_ENTITY-MANDT .
ZODATA_ENTITY-NAMESPACE =
ZODATA_V_ENTITY-NAMESPACE .
ZODATA_ENTITY-ENTITY_NAME =
ZODATA_V_ENTITY-ENTITY_NAME .
ZODATA_ENTITY-CLASS_NAME =
ZODATA_V_ENTITY-CLASS_NAME .
ZODATA_ENTITY-STRUCTURE =
ZODATA_V_ENTITY-STRUCTURE .
ZODATA_ENTITY-IS_COMPLEX =
ZODATA_V_ENTITY-IS_COMPLEX .
ZODATA_ENTITY-DEEP_ENTITY_STRUCTURE =
ZODATA_V_ENTITY-DEEP_ENTITY_STRUCTURE .
ZODATA_ENTITY-IS_MEDIA =
ZODATA_V_ENTITY-IS_MEDIA .
    IF SY-SUBRC = 0.
    UPDATE ZODATA_ENTITY ##WARN_OK.
    ELSE.
    INSERT ZODATA_ENTITY .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZODATA_V_ENTITY-UPD_FLAG,
STATUS_ZODATA_V_ENTITY-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZODATA_V_ENTITY.
  SELECT SINGLE * FROM ZODATA_ENTITY WHERE
NAMESPACE = ZODATA_V_ENTITY-NAMESPACE AND
ENTITY_NAME = ZODATA_V_ENTITY-ENTITY_NAME .
ZODATA_V_ENTITY-MANDT =
ZODATA_ENTITY-MANDT .
ZODATA_V_ENTITY-NAMESPACE =
ZODATA_ENTITY-NAMESPACE .
ZODATA_V_ENTITY-ENTITY_NAME =
ZODATA_ENTITY-ENTITY_NAME .
ZODATA_V_ENTITY-CLASS_NAME =
ZODATA_ENTITY-CLASS_NAME .
ZODATA_V_ENTITY-STRUCTURE =
ZODATA_ENTITY-STRUCTURE .
ZODATA_V_ENTITY-IS_COMPLEX =
ZODATA_ENTITY-IS_COMPLEX .
ZODATA_V_ENTITY-DEEP_ENTITY_STRUCTURE =
ZODATA_ENTITY-DEEP_ENTITY_STRUCTURE .
ZODATA_V_ENTITY-IS_MEDIA =
ZODATA_ENTITY-IS_MEDIA .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZODATA_V_ENTITY USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZODATA_V_ENTITY-NAMESPACE TO
ZODATA_ENTITY-NAMESPACE .
MOVE ZODATA_V_ENTITY-ENTITY_NAME TO
ZODATA_ENTITY-ENTITY_NAME .
MOVE ZODATA_V_ENTITY-MANDT TO
ZODATA_ENTITY-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZODATA_ENTITY'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZODATA_ENTITY TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZODATA_ENTITY'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZODATA_V_NAV....................................*
FORM GET_DATA_ZODATA_V_NAV.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZODATA_NAV WHERE
(VIM_WHERETAB) .
    CLEAR ZODATA_V_NAV .
ZODATA_V_NAV-MANDT =
ZODATA_NAV-MANDT .
ZODATA_V_NAV-NAMESPACE =
ZODATA_NAV-NAMESPACE .
ZODATA_V_NAV-NAV_PROP =
ZODATA_NAV-NAV_PROP .
ZODATA_V_NAV-FROM_ENTITY =
ZODATA_NAV-FROM_ENTITY .
ZODATA_V_NAV-TO_ENTITY =
ZODATA_NAV-TO_ENTITY .
ZODATA_V_NAV-CARDINALITY =
ZODATA_NAV-CARDINALITY .
<VIM_TOTAL_STRUC> = ZODATA_V_NAV.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZODATA_V_NAV .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZODATA_V_NAV.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZODATA_V_NAV-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_NAV WHERE
  NAMESPACE = ZODATA_V_NAV-NAMESPACE AND
  NAV_PROP = ZODATA_V_NAV-NAV_PROP .
    IF SY-SUBRC = 0.
    DELETE ZODATA_NAV .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_NAV WHERE
  NAMESPACE = ZODATA_V_NAV-NAMESPACE AND
  NAV_PROP = ZODATA_V_NAV-NAV_PROP .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZODATA_NAV.
    ENDIF.
ZODATA_NAV-MANDT =
ZODATA_V_NAV-MANDT .
ZODATA_NAV-NAMESPACE =
ZODATA_V_NAV-NAMESPACE .
ZODATA_NAV-NAV_PROP =
ZODATA_V_NAV-NAV_PROP .
ZODATA_NAV-FROM_ENTITY =
ZODATA_V_NAV-FROM_ENTITY .
ZODATA_NAV-TO_ENTITY =
ZODATA_V_NAV-TO_ENTITY .
ZODATA_NAV-CARDINALITY =
ZODATA_V_NAV-CARDINALITY .
    IF SY-SUBRC = 0.
    UPDATE ZODATA_NAV ##WARN_OK.
    ELSE.
    INSERT ZODATA_NAV .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZODATA_V_NAV-UPD_FLAG,
STATUS_ZODATA_V_NAV-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZODATA_V_NAV.
  SELECT SINGLE * FROM ZODATA_NAV WHERE
NAMESPACE = ZODATA_V_NAV-NAMESPACE AND
NAV_PROP = ZODATA_V_NAV-NAV_PROP .
ZODATA_V_NAV-MANDT =
ZODATA_NAV-MANDT .
ZODATA_V_NAV-NAMESPACE =
ZODATA_NAV-NAMESPACE .
ZODATA_V_NAV-NAV_PROP =
ZODATA_NAV-NAV_PROP .
ZODATA_V_NAV-FROM_ENTITY =
ZODATA_NAV-FROM_ENTITY .
ZODATA_V_NAV-TO_ENTITY =
ZODATA_NAV-TO_ENTITY .
ZODATA_V_NAV-CARDINALITY =
ZODATA_NAV-CARDINALITY .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZODATA_V_NAV USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZODATA_V_NAV-NAMESPACE TO
ZODATA_NAV-NAMESPACE .
MOVE ZODATA_V_NAV-NAV_PROP TO
ZODATA_NAV-NAV_PROP .
MOVE ZODATA_V_NAV-MANDT TO
ZODATA_NAV-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZODATA_NAV'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZODATA_NAV TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZODATA_NAV'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZODATA_V_PROP...................................*
FORM GET_DATA_ZODATA_V_PROP.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZODATA_PROPERTY WHERE
(VIM_WHERETAB) .
    CLEAR ZODATA_V_PROP .
ZODATA_V_PROP-MANDT =
ZODATA_PROPERTY-MANDT .
ZODATA_V_PROP-NAMESPACE =
ZODATA_PROPERTY-NAMESPACE .
ZODATA_V_PROP-ENTITY_NAME =
ZODATA_PROPERTY-ENTITY_NAME .
ZODATA_V_PROP-PROPERTY_NAME =
ZODATA_PROPERTY-PROPERTY_NAME .
ZODATA_V_PROP-ABAP_NAME =
ZODATA_PROPERTY-ABAP_NAME .
ZODATA_V_PROP-IS_KEY =
ZODATA_PROPERTY-IS_KEY .
ZODATA_V_PROP-COMPLEX_TYPE =
ZODATA_PROPERTY-COMPLEX_TYPE .
ZODATA_V_PROP-SEARCH_HELP =
ZODATA_PROPERTY-SEARCH_HELP .
ZODATA_V_PROP-AS_ETAG =
ZODATA_PROPERTY-AS_ETAG .
ZODATA_V_PROP-NOT_FILTERABLE =
ZODATA_PROPERTY-NOT_FILTERABLE .
ZODATA_V_PROP-NOT_EDITABLE =
ZODATA_PROPERTY-NOT_EDITABLE .
ZODATA_V_PROP-SORT_ORDER =
ZODATA_PROPERTY-SORT_ORDER .
ZODATA_V_PROP-FILTER_IN_FILTERBAR =
ZODATA_PROPERTY-FILTER_IN_FILTERBAR .
ZODATA_V_PROP-MANDATORY_FILTER =
ZODATA_PROPERTY-MANDATORY_FILTER .
ZODATA_V_PROP-NOT_VISIBLE =
ZODATA_PROPERTY-NOT_VISIBLE .
<VIM_TOTAL_STRUC> = ZODATA_V_PROP.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZODATA_V_PROP .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZODATA_V_PROP.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZODATA_V_PROP-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_PROPERTY WHERE
  NAMESPACE = ZODATA_V_PROP-NAMESPACE AND
  ENTITY_NAME = ZODATA_V_PROP-ENTITY_NAME AND
  PROPERTY_NAME = ZODATA_V_PROP-PROPERTY_NAME .
    IF SY-SUBRC = 0.
    DELETE ZODATA_PROPERTY .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_PROPERTY WHERE
  NAMESPACE = ZODATA_V_PROP-NAMESPACE AND
  ENTITY_NAME = ZODATA_V_PROP-ENTITY_NAME AND
  PROPERTY_NAME = ZODATA_V_PROP-PROPERTY_NAME .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZODATA_PROPERTY.
    ENDIF.
ZODATA_PROPERTY-MANDT =
ZODATA_V_PROP-MANDT .
ZODATA_PROPERTY-NAMESPACE =
ZODATA_V_PROP-NAMESPACE .
ZODATA_PROPERTY-ENTITY_NAME =
ZODATA_V_PROP-ENTITY_NAME .
ZODATA_PROPERTY-PROPERTY_NAME =
ZODATA_V_PROP-PROPERTY_NAME .
ZODATA_PROPERTY-ABAP_NAME =
ZODATA_V_PROP-ABAP_NAME .
ZODATA_PROPERTY-IS_KEY =
ZODATA_V_PROP-IS_KEY .
ZODATA_PROPERTY-COMPLEX_TYPE =
ZODATA_V_PROP-COMPLEX_TYPE .
ZODATA_PROPERTY-SEARCH_HELP =
ZODATA_V_PROP-SEARCH_HELP .
ZODATA_PROPERTY-AS_ETAG =
ZODATA_V_PROP-AS_ETAG .
ZODATA_PROPERTY-NOT_FILTERABLE =
ZODATA_V_PROP-NOT_FILTERABLE .
ZODATA_PROPERTY-NOT_EDITABLE =
ZODATA_V_PROP-NOT_EDITABLE .
ZODATA_PROPERTY-SORT_ORDER =
ZODATA_V_PROP-SORT_ORDER .
ZODATA_PROPERTY-FILTER_IN_FILTERBAR =
ZODATA_V_PROP-FILTER_IN_FILTERBAR .
ZODATA_PROPERTY-MANDATORY_FILTER =
ZODATA_V_PROP-MANDATORY_FILTER .
ZODATA_PROPERTY-NOT_VISIBLE =
ZODATA_V_PROP-NOT_VISIBLE .
    IF SY-SUBRC = 0.
    UPDATE ZODATA_PROPERTY ##WARN_OK.
    ELSE.
    INSERT ZODATA_PROPERTY .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZODATA_V_PROP-UPD_FLAG,
STATUS_ZODATA_V_PROP-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZODATA_V_PROP.
  SELECT SINGLE * FROM ZODATA_PROPERTY WHERE
NAMESPACE = ZODATA_V_PROP-NAMESPACE AND
ENTITY_NAME = ZODATA_V_PROP-ENTITY_NAME AND
PROPERTY_NAME = ZODATA_V_PROP-PROPERTY_NAME .
ZODATA_V_PROP-MANDT =
ZODATA_PROPERTY-MANDT .
ZODATA_V_PROP-NAMESPACE =
ZODATA_PROPERTY-NAMESPACE .
ZODATA_V_PROP-ENTITY_NAME =
ZODATA_PROPERTY-ENTITY_NAME .
ZODATA_V_PROP-PROPERTY_NAME =
ZODATA_PROPERTY-PROPERTY_NAME .
ZODATA_V_PROP-ABAP_NAME =
ZODATA_PROPERTY-ABAP_NAME .
ZODATA_V_PROP-IS_KEY =
ZODATA_PROPERTY-IS_KEY .
ZODATA_V_PROP-COMPLEX_TYPE =
ZODATA_PROPERTY-COMPLEX_TYPE .
ZODATA_V_PROP-SEARCH_HELP =
ZODATA_PROPERTY-SEARCH_HELP .
ZODATA_V_PROP-AS_ETAG =
ZODATA_PROPERTY-AS_ETAG .
ZODATA_V_PROP-NOT_FILTERABLE =
ZODATA_PROPERTY-NOT_FILTERABLE .
ZODATA_V_PROP-NOT_EDITABLE =
ZODATA_PROPERTY-NOT_EDITABLE .
ZODATA_V_PROP-SORT_ORDER =
ZODATA_PROPERTY-SORT_ORDER .
ZODATA_V_PROP-FILTER_IN_FILTERBAR =
ZODATA_PROPERTY-FILTER_IN_FILTERBAR .
ZODATA_V_PROP-MANDATORY_FILTER =
ZODATA_PROPERTY-MANDATORY_FILTER .
ZODATA_V_PROP-NOT_VISIBLE =
ZODATA_PROPERTY-NOT_VISIBLE .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZODATA_V_PROP USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZODATA_V_PROP-NAMESPACE TO
ZODATA_PROPERTY-NAMESPACE .
MOVE ZODATA_V_PROP-ENTITY_NAME TO
ZODATA_PROPERTY-ENTITY_NAME .
MOVE ZODATA_V_PROP-PROPERTY_NAME TO
ZODATA_PROPERTY-PROPERTY_NAME .
MOVE ZODATA_V_PROP-MANDT TO
ZODATA_PROPERTY-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZODATA_PROPERTY'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZODATA_PROPERTY TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZODATA_PROPERTY'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZODATA_V_PROPTXT................................*
FORM GET_DATA_ZODATA_V_PROPTXT.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZODATA_PROP_TXTS WHERE
(VIM_WHERETAB) .
    CLEAR ZODATA_V_PROPTXT .
ZODATA_V_PROPTXT-MANDT =
ZODATA_PROP_TXTS-MANDT .
ZODATA_V_PROPTXT-NAMESPACE =
ZODATA_PROP_TXTS-NAMESPACE .
ZODATA_V_PROPTXT-ENTITY_NAME =
ZODATA_PROP_TXTS-ENTITY_NAME .
ZODATA_V_PROPTXT-PROPERTY_NAME =
ZODATA_PROP_TXTS-PROPERTY_NAME .
ZODATA_V_PROPTXT-TEXT_TYPE =
ZODATA_PROP_TXTS-TEXT_TYPE .
ZODATA_V_PROPTXT-TEXT_ID =
ZODATA_PROP_TXTS-TEXT_ID .
ZODATA_V_PROPTXT-OBJECT_NAME =
ZODATA_PROP_TXTS-OBJECT_NAME .
<VIM_TOTAL_STRUC> = ZODATA_V_PROPTXT.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZODATA_V_PROPTXT .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZODATA_V_PROPTXT.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZODATA_V_PROPTXT-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_PROP_TXTS WHERE
  NAMESPACE = ZODATA_V_PROPTXT-NAMESPACE AND
  ENTITY_NAME = ZODATA_V_PROPTXT-ENTITY_NAME AND
  PROPERTY_NAME = ZODATA_V_PROPTXT-PROPERTY_NAME AND
  TEXT_TYPE = ZODATA_V_PROPTXT-TEXT_TYPE .
    IF SY-SUBRC = 0.
    DELETE ZODATA_PROP_TXTS .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZODATA_PROP_TXTS WHERE
  NAMESPACE = ZODATA_V_PROPTXT-NAMESPACE AND
  ENTITY_NAME = ZODATA_V_PROPTXT-ENTITY_NAME AND
  PROPERTY_NAME = ZODATA_V_PROPTXT-PROPERTY_NAME AND
  TEXT_TYPE = ZODATA_V_PROPTXT-TEXT_TYPE .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZODATA_PROP_TXTS.
    ENDIF.
ZODATA_PROP_TXTS-MANDT =
ZODATA_V_PROPTXT-MANDT .
ZODATA_PROP_TXTS-NAMESPACE =
ZODATA_V_PROPTXT-NAMESPACE .
ZODATA_PROP_TXTS-ENTITY_NAME =
ZODATA_V_PROPTXT-ENTITY_NAME .
ZODATA_PROP_TXTS-PROPERTY_NAME =
ZODATA_V_PROPTXT-PROPERTY_NAME .
ZODATA_PROP_TXTS-TEXT_TYPE =
ZODATA_V_PROPTXT-TEXT_TYPE .
ZODATA_PROP_TXTS-TEXT_ID =
ZODATA_V_PROPTXT-TEXT_ID .
ZODATA_PROP_TXTS-OBJECT_NAME =
ZODATA_V_PROPTXT-OBJECT_NAME .
    IF SY-SUBRC = 0.
    UPDATE ZODATA_PROP_TXTS ##WARN_OK.
    ELSE.
    INSERT ZODATA_PROP_TXTS .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZODATA_V_PROPTXT-UPD_FLAG,
STATUS_ZODATA_V_PROPTXT-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZODATA_V_PROPTXT.
  SELECT SINGLE * FROM ZODATA_PROP_TXTS WHERE
NAMESPACE = ZODATA_V_PROPTXT-NAMESPACE AND
ENTITY_NAME = ZODATA_V_PROPTXT-ENTITY_NAME AND
PROPERTY_NAME = ZODATA_V_PROPTXT-PROPERTY_NAME AND
TEXT_TYPE = ZODATA_V_PROPTXT-TEXT_TYPE .
ZODATA_V_PROPTXT-MANDT =
ZODATA_PROP_TXTS-MANDT .
ZODATA_V_PROPTXT-NAMESPACE =
ZODATA_PROP_TXTS-NAMESPACE .
ZODATA_V_PROPTXT-ENTITY_NAME =
ZODATA_PROP_TXTS-ENTITY_NAME .
ZODATA_V_PROPTXT-PROPERTY_NAME =
ZODATA_PROP_TXTS-PROPERTY_NAME .
ZODATA_V_PROPTXT-TEXT_TYPE =
ZODATA_PROP_TXTS-TEXT_TYPE .
ZODATA_V_PROPTXT-TEXT_ID =
ZODATA_PROP_TXTS-TEXT_ID .
ZODATA_V_PROPTXT-OBJECT_NAME =
ZODATA_PROP_TXTS-OBJECT_NAME .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZODATA_V_PROPTXT USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZODATA_V_PROPTXT-NAMESPACE TO
ZODATA_PROP_TXTS-NAMESPACE .
MOVE ZODATA_V_PROPTXT-ENTITY_NAME TO
ZODATA_PROP_TXTS-ENTITY_NAME .
MOVE ZODATA_V_PROPTXT-PROPERTY_NAME TO
ZODATA_PROP_TXTS-PROPERTY_NAME .
MOVE ZODATA_V_PROPTXT-TEXT_TYPE TO
ZODATA_PROP_TXTS-TEXT_TYPE .
MOVE ZODATA_V_PROPTXT-MANDT TO
ZODATA_PROP_TXTS-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZODATA_PROP_TXTS'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZODATA_PROP_TXTS TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZODATA_PROP_TXTS'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*

* base table related FORM-routines.............
INCLUDE LSVIMFTX .
