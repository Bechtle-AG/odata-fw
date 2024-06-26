"! <p class="shorttext synchronized" lang="de">Odata Error Class</p>
CLASS zcx_odata DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.
    INTERFACES if_t100_dyn_msg.

    CONSTANTS:
      BEGIN OF no_filter_passed,
        msgid TYPE symsgid      VALUE 'Z_ODATA',
        msgno TYPE symsgno      VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_filter_passed.
    CONSTANTS:
      BEGIN OF no_structure,
        msgid TYPE symsgid      VALUE 'Z_ODATA',
        msgno TYPE symsgno      VALUE '002',
        attr1 TYPE scx_attrname VALUE 'VALUE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_structure.
    CONSTANTS:
      BEGIN OF no_entities,
        msgid TYPE symsgid      VALUE 'Z_ODATA',
        msgno TYPE symsgno      VALUE '003',
        attr1 TYPE scx_attrname VALUE 'VALUE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_entities.
    CONSTANTS:
      BEGIN OF no_properties,
        msgid TYPE symsgid      VALUE 'Z_ODATA',
        msgno TYPE symsgno      VALUE '004',
        attr1 TYPE scx_attrname VALUE 'VALUE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_properties.
    CONSTANTS:
      BEGIN OF component_not_in_structure,
        msgid TYPE symsgid      VALUE 'Z_ODATA',
        msgno TYPE symsgno      VALUE '005',
        attr1 TYPE scx_attrname VALUE 'VALUE',
        attr2 TYPE scx_attrname VALUE 'VALUE2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF component_not_in_structure.
    CONSTANTS:
      BEGIN OF only_one_filter_id,
        msgid TYPE symsgid      VALUE 'Z_ODATA',
        msgno TYPE symsgno      VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF only_one_filter_id.
    CONSTANTS:
      BEGIN OF no_search_help_found,
        msgid TYPE symsgid      VALUE 'Z_ODATA',
        msgno TYPE symsgno      VALUE '007',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_search_help_found.
    CONSTANTS:
      BEGIN OF action_not_implemented,
        msgid TYPE symsgid      VALUE 'Z_ODATA',
        msgno TYPE symsgno      VALUE '008',
        attr1 TYPE scx_attrname VALUE 'VALUE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF action_not_implemented.
    CONSTANTS:
      BEGIN OF gc_column_not_found_in_table,
        msgid TYPE symsgid      VALUE 'Z_ODATA',
        msgno TYPE symsgno      VALUE '009',
        attr1 TYPE scx_attrname VALUE 'VALUE',
        attr2 TYPE scx_attrname VALUE 'VALUE2',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF gc_column_not_found_in_table.

    DATA value  TYPE string.
    DATA value2 TYPE string.

    "! <p class="shorttext synchronized">Convert message</p>
    "!
    "! @parameter I_MSGID  | <p class="shorttext synchronized">Message id</p>
    "! @parameter I_MSGNO  | <p class="shorttext synchronized">Message number</p>
    "! @parameter I_MSGV1  | <p class="shorttext synchronized">Message attribute 1</p>
    "! @parameter I_MSGV2  | <p class="shorttext synchronized">Message attribute 2</p>
    "! @parameter I_MSGV3  | <p class="shorttext synchronized">Message attribute 3</p>
    "! @parameter I_MSGV4  | <p class="shorttext synchronized">Message attribute 4</p>
    "! @parameter R_TEXTID | <p class="shorttext synchronized">Error structure</p>
    CLASS-METHODS convert_msg
      IMPORTING i_msgid         TYPE syst_msgid DEFAULT sy-msgid
                i_msgno         TYPE syst_msgno DEFAULT sy-msgno
                i_msgv1         TYPE syst_msgv  DEFAULT sy-msgv1
                i_msgv2         TYPE syst_msgv  DEFAULT sy-msgv2
                i_msgv3         TYPE syst_msgv  DEFAULT sy-msgv3
                i_msgv4         TYPE syst_msgv  DEFAULT sy-msgv4
      RETURNING VALUE(r_textid) LIKE if_t100_message=>t100key.

    "! <p class="shorttext synchronized">Convert bapiret2 structure to error structure</p>
    "!
    "! @parameter I_RETURN | <p class="shorttext synchronized">Bapi return 2 structure</p>
    "! @parameter R_TEXTID | <p class="shorttext synchronized">Error structure</p>
    CLASS-METHODS convert_bapiret2
      IMPORTING i_return        TYPE bapiret2
      RETURNING VALUE(r_textid) LIKE if_t100_message=>t100key.

    "! <p class="shorttext synchronized">CONSTRUCTOR</p>
    "!
    "! @parameter TEXTID   | <p class="shorttext synchronized">Message id</p>
    "! @parameter PREVIOUS | <p class="shorttext synchronized">Previous exception</p>
    "! @parameter VALUE    | <p class="shorttext synchronized">Message attribute 1</p>
    "! @parameter VALUE2   | <p class="shorttext synchronized">Message attribute 2</p>
    METHODS constructor
      IMPORTING textid    LIKE if_t100_message=>t100key OPTIONAL
                !previous LIKE previous                 OPTIONAL
                !value    TYPE string                   OPTIONAL
                value2    TYPE string                   OPTIONAL.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS zcx_odata IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    me->value  = value.
    me->value2 = value2.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

  METHOD convert_bapiret2.
    r_textid = VALUE #( msgid = i_return-id
                        msgno = i_return-number
                        attr1 = i_return-message_v1
                        attr2 = i_return-message_v2
                        attr3 = i_return-message_v3
                        attr4 = i_return-message_v4 ).
  ENDMETHOD.

  METHOD convert_msg.
    r_textid = VALUE #( msgid = i_msgid
                        msgno = i_msgno
                        attr1 = i_msgv1
                        attr2 = i_msgv2
                        attr3 = i_msgv3
                        attr4 = i_msgv4 ).
  ENDMETHOD.
ENDCLASS.
