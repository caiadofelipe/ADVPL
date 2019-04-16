// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : XANCONF.prw
// -----------+-------------------+---------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+---------------------------------------------------------
// 12/07/2018 | raphael.neves     | Gerado com auxílio do Assistente de Código do TDS.
// -----------+-------------------+---------------------------------------------------------

#include "protheus.ch"
#include "vkey.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWBROWSE.CH"

Static __lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Static __cWmsLcFt := SuperGetMV('MV_WMSLCFT',.F.,'') // Local de falta
Static __cWmsLcEx := SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
Static __cWmsEnEx := SuperGetMV('MV_WMSENEX',.F.,"") // Endereço de excesso

Static oBrwDCW, oBrwDCX, oBrwDCY, oBrwDCZ, oTimer

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} XANCONF
Manutenção de dados em DCW-Conferencia de Recebimento.

@author    raphael.neves
@version   11.3.9.201806061959
@since     12/07/2018
/*/
//------------------------------------------------------------------------------------------

User Function XANCONF()

Local lWmsCRD  := SuperGetMV("MV_WMSCRD",.F.,.F.)
Local nTime    := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local lRefresh := .T.

Private nTipConf  := 1
Private cArmazem  := Space(TamSX3("BE_LOCAL")[1])
Private cEndereco := Space(TamSX3("BE_LOCALIZ")[1])
Private cIdUnit   := ""
Private cTipUni   := ""
Private lUnitiza  := .F.
Private lSolEnd   := .T.

	If !IntWMS() .And. !lWmsCRD
		WmsMessage("Permitida utilização somente com Integração com o WMS (MV_INTWMS) ou integração com a conferência de recebimento WMS (MV_WMSCRD)!","WMSA32028",1) //
		Return
	EndIf

	If __lWmsNew .And. (__cWmsLcFt == __cWmsLcEx) .And. !Empty(__cWmsLcFt)
		WmsMessage("Armazém de falta e excesso não podem ser iguais. MV_WMSLCFT e MV_WMSLCEX","WMSA32027",1) //
		Return
	EndIf

	If !WmsX312118("DCY","DCY_LOCAL") .Or. !WmsX312118("DCZ","DCZ_LOCAL")
		WmsMessage("Para o correto funcionamento desta rotina favor seguir os procedimentos descritos em: "+CRLF+"http://tdn.totvs.com/pages/viewpage.action?pageId=286507592","WMSA32084",1) // "Armazém de falta e excesso não podem ser iguais. MV_WMSLCFT e MV_WMSLCEX"
		Return
	EndIf

	cIdUnit := Space(TamSX3("D0R_IDUNIT")[1])
	cTipUni := Space(TamSX3("D0R_CODUNI")[1])

	If Pergunte("WMSA320",.T.)

// Avalia se os parâmetros estão preenchidos e informa o usuário
//		WMSA320Par()

		lRefresh := (MV_PAR05 < 4) // Salva parametros do Pergunte

		// Ajusta o dicionário de dados para tratar a nova opção 4=Conferido com divergência
		oBrwDCW := FWMBrowse():New()
		oBrwDCW:SetAlias('DCW')                               // Alias da tabela utilizada
		oBrwDCW:SetAmbiente(.F.)
		oBrwDCW:SetWalkThru(.F.)
		oBrwDCW:SetMenuDef('XANCONF')                         // Nome do fonte onde esta a função MenuDef
		oBrwDCW:SetDescription("Conferência Recebimento")                       //
		oBrwDCW:AddLegend("DCW_SITEMB=='1'",'RED'   ,"Não iniciado") //
/*
		If __lWmsNew
			oBrwDCW:AddLegend("DCW_SITEMB=='2'",'ORANGE',"Volume em Andamento") //
			oBrwDCW:AddLegend("DCW_SITEMB=='3'",'VIOLET',"Volume Conferido") //
			oBrwDCW:AddLegend("DCW_SITEMB=='4'",'BROWN' ,"Volume Conferido com Divergência") //
		EndIf
*/
		oBrwDCW:AddLegend("DCW_SITEMB=='5'",'YELLOW',"Conferencia em Andamento") //
		oBrwDCW:AddLegend("DCW_SITEMB=='6'",'GREEN' ,"Conferido") // Produto Conferido
		oBrwDCW:AddLegend("DCW_SITEMB=='7'",'BLUE'  ,"Conferido com Divergência") //
		oBrwDCW:SetFilterDefault("@"+Filtro())
		oBrwDCW:SetParam({|| SelFiltro(.T.) })
		oBrwDCW:SetTimer({|| Iif(lRefresh,SelFiltro(.F.),.T.) }, Iif(nTime<=0, 3600, nTime) * 1000)
		oBrwDCW:DisableDetails()
		oBrwDCW:SetFixedBrowse(.T.)
		oBrwDCW:SetProfileID('1')
		oBrwDCW:Activate()
	EndIf

Return Nil

Static Function MenuDef()

Private aRotina := {}

ADD OPTION aRotina TITLE "Conferir"					ACTION 'U_XANCONFI(1)'    							OPERATION 2  ACCESS 0 DISABLE MENU // Montagem
ADD OPTION aRotina TITLE "Consultar Paletes"		ACTION 'U_AN_CONFDG(DCW->DCW_EMBARQ)'				OPERATION 2  ACCESS 0 DISABLE MENU // Visualizar
ADD OPTION aRotina TITLE "Imprimir Palete" 			ACTION 'U_RCONFREC()'								OPERATION 10 ACCESS 0 DISABLE MENU //
ADD OPTION aRotina TITLE "Relatório Conferencia" 	ACTION 'u_ANWMSR325(2)'                        		OPERATION 10 ACCESS 0 DISABLE MENU //
ADD OPTION aRotina TITLE "Reabrir Palete" 			ACTION 'U_XOPENPAL(DCW->DCW_EMBARQ)'				OPERATION 2  ACCESS 0 DISABLE MENU //
ADD OPTION aRotina TITLE "Manutenção Palete"		ACTION "StaticCall(XANCONF,MNT_PAL)"				OPERATION 2  ACCESS 0 DISABLE MENU //
ADD OPTION aRotina TITLE "Finalizar Conferência" 	ACTION 'U_FinCofRAN(DCW->DCW_EMBARQ)'				OPERATION 2  ACCESS 0 DISABLE MENU //
ADD OPTION aRotina TITLE "Reabrir Conferência" 		ACTION 'u_AN_ReCo()'								OPERATION 2  ACCESS 0 DISABLE MENU //
ADD OPTION aRotina TITLE "Excluir Paletes Iniciados" ACTION 'U_XANCONFE(DCW->DCW_EMBARQ)'		        OPERATION 5  ACCESS 0 DISABLE MENU // Excluir

Return aRotina
//------------------------------------------------------------------------------------------------------------------------------------------------------
//
User Function XANCONFE(cEmbarque)

Local _aArea := GetArea()
Local _lContinua := .t.
Local _aNFClass  := {}
If DCW->DCW_SITEMB $ "6/7"
	Help( NIL, NIL, "ROMENC", NIL, "Conferencia finalizada, não é possivel excluir", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para excluir os Paletes deverá ser estornada o encerramento da conferencia."})
	Return
Endif
IF !MsgYesNo("Este procedimento irá excluir TODOS os Paletes gerados. Deseja continuar?")
	Return
Endif
Begin Transaction
DCX->( dbSetOrder(1) )
IF DCX->( dbSeek(xFilial('DCX')+cEmbarque) )
	While !DCX->(Eof()) .and. cEmbarque == DCX->DCX_EMBARQ
		DbSelectArea("SD1")
		SD1->(dbSeek(xFilial("SD1") + DCX->(DCX_DOC + DCX_SERIE + DCX_FORNEC + DCX_LOJA)) )
		While !SD1->(Eof()) .and. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == xFilial("SD1") + DCX->(DCX_DOC + DCX_SERIE + DCX_FORNEC + DCX_LOJA)
			IF !Empty(SD1->D1_TES)
				_lContinua := .F.
				aadd(_aNFClass, {D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA})
			Endif
			SD1->(DbSkip())
		EndDo
		DCX->(DbSkip())
	EndDo
	If _lContinua
		DCY->( dbSetOrder(1) )
		IF DCY->( dbSeek(xFilial('DCY')+cEmbarque))
			While !DCY->(Eof()) .and. cEmbarque == DCY->DCY_EMBARQ
				If DCY->DCY_QTORIG > 0
					If DCY->DCY_QTCONF > 0
						RecLock("DCY",.F.)
						Replace DCY_QTCONF with 0
						DCY->(MsUnlock())
					Endif
				Else
					RecLock("DCY",.F.)
					DCY->(DbDelete())
					DCY->(MsUnlock())
				Endif
				DCY->(DbSkip())
			EndDo
		Endif
		DCZ->( dbSetOrder(1) )
		IF DCZ->( dbSeek(xFilial('DCZ')+cEmbarque))
			While !DCZ->(Eof()) .and. cEmbarque == DCZ->DCZ_EMBARQ
				RecLock("DCZ",.F.)
				DCZ->(DbDelete())
				DCZ->(MsUnlock())
				DCZ->(DbSkip())
			EndDo
		Endif
		ZCZ->( dbSetOrder(1) )
		IF ZCZ->( dbSeek(xFilial('ZCZ')+cEmbarque))
			While !ZCZ->(Eof()) .and. cEmbarque == ZCZ->ZCZ_EMBARQ
				RecLock("ZCZ",.F.)
				ZCZ->(DbDelete())
				ZCZ->(MsUnlock())
				ZCZ->(DbSkip())
			EndDo
		Endif
		ZZL->( dbSetOrder(1) )
		IF ZZL->( dbSeek(xFilial('ZZL')+cEmbarque))
			While !ZZL->(Eof()) .and. cEmbarque == ZZL->ZZL_EMBARQ
				RecLock("ZZL",.F.)
				ZZL->(DbDelete())
				ZZL->(MsUnlock())
				ZZL->(DbSkip())
			EndDo
		Endif
		dbSelectArea("DCW")
		dbSetOrder(1)
		If dbSeek(xFilial()+cEmbarque)
			RecLock("DCW",.F.)
			Replace DCW_SITEMB with "1"
			MsUnLock()
		Endif
	Else
		Help( NIL, NIL, "NFCLASSIF", NIL, "Não é possível excluir os Paletes, pois existem notas classificadas!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para excluir os Paletes deverá ser estornada a Classificação da NF."})
	Endif
	/*
	DbSelectArea("DB1")
	DB1->(DbSetOrder(1))
	IF DB1->(MsSeek(xFilial("DB1") + cEmbarque))
	While !DB1->(Eof()) .and. cEmbarque == DB1->DB1_NRAVRC
	RecLock("DB1",.F.)
	DB1->(DbDelete())
	DB1->(MsUnlock())
	DB1->(DbSkip())
	EndDo
	Endif
	DbSelectArea("DB2")
	DB2->(DbSetOrder(2))
	IF DB2->(MsSeek(xFilial("DB2") + cEmbarque))
	While !DB2->(Eof()) .and. cEmbarque == DB2->DB2_NRAVRC
	RecLock("DB2",.F.)
	DB2->(DbDelete())
	DB2->(MsUnlock())

	DB2->(DbSkip())
	EndDo
	Endif
	DbSelectArea("DB3")
	DB3->(DbSetOrder(1))
	IF DB3->(MsSeek(xFilial("DB3") + cEmbarque))
	While !DB3->(Eof()) .and. cEmbarque == DB3->DB3_NRAVRC
	RecLock("DB3",.F.)
	DB3->(DbDelete())
	DB3->(MsUnlock())

	DB3->(DbSkip())
	EndDo
	Endif
	*/

Endif
End Transaction
RestArea(_aArea)
Return
//----------------------------------------------------------------------------------------------------------------
//
Static Function MNT_PAL

Local _aArea := GetArea()

If DCW->DCW_SITEMB $ '6/7'
	Help( NIL, NIL, "ROMFINAL", NIL, "Romaneio finalizado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para fazer a manutenção é necessário estornar a finalização do Romaneio."})
Else
	dbSelectArea("ZZL")
	dbSetOrder(1)
	If dbSeek(xFilial()+DCW->DCW_EMBARQ)
		u_AN_MNTPAL(DCW->DCW_EMBARQ)
	Else
		Help( NIL, NIL, "ROMNINIC", NIL, "Romaneio não iniciado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Não encontrado palete para fazer manutenção."})
	Endif
Endif
Return

//----------------------------------------------------------------------------------------------------------------
//
User Function XOPENPAL(cEmbarque)

Local _aArea	:= GetArea()
Local cOpera
Local cQuery := ""
Local aButtons
Private oDlg
Private oLbx1
Private aDados := {}
Private oOk		:= LoadBitmap( GetResources(), "CHECKED" )
Private oNo		:= LoadBitmap( GetResources(), "UNCHECKED" )

DbSelectArea("DCD")
DCD->(DbSetOrder(1))
IF DCD->(MsSeek(xFilial("DCD") + RetCodUsr()))
	cOpera := DCD->DCD_CODFUN
Else
	//		Help( Nil, Nil, , Nil, "Usuário não é operador", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Cadastrar usuário como operador."})
	Help( NIL, NIL, "ANLTOTVS", NIL, "Usuário não é operador", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Cadastrar usuário como operador."})
	Return
Endif

cQuery := " "
cQuery += " SELECT DISTINCT ZZL_EMBARQ, ZZL_PALETE FROM " + RetSqlName("ZZL")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND ZZL_FILIAL = '"+xFilial("ZZL")+"' "
cQuery += " AND ZZL_OPER = '"+cOpera+"' "
cQuery += " AND ZZL_EMBARQ = '"+cEmbarque+"' "
cQuery += " AND ZZL_DTFECH = '        ' "
cQuery += " ORDER BY ZZL_EMBARQ, ZZL_PALETE"
cQuery := ChangeQuery(cQuery)
IF Select("TMP") > 0
	TMP->(DbCloseArea())
EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)
IF !TMP->(Eof())
	Aviso("Reabrir palete","Operador possui Paletes em aberto, não permitido ter mais de 1 palete em aberto.",{"OK"},1)
	TMP->(DbCloseArea())
	Return
Endif
TMP->(DbCloseArea())
RestArea(_aArea)
cQuery := " "
cQuery += " SELECT DISTINCT ZZL_EMBARQ, ZZL_PALETE FROM " + RetSqlName("ZZL")
cQuery += " WHERE D_E_L_E_T_ <> '*' "
cQuery += " AND ZZL_FILIAL = '"+xFilial("ZZL")+"' "
cQuery += " AND ZZL_OPER = '"+cOpera+"' "
cQuery += " AND ZZL_EMBARQ = '"+cEmbarque+"' "
cQuery += " AND ZZL_DTFECH <> '        ' "
cQuery += " ORDER BY ZZL_EMBARQ, ZZL_PALETE"
cQuery := ChangeQuery(cQuery)
IF Select("TMP") > 0
	TMP->(DbCloseArea())
EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.F.,.T.)

IF !TMP->(Eof())
	While !TMP->(Eof())
		aAdd(aDados,{.F.,TMP->ZZL_EMBARQ,TMP->ZZL_PALETE})

		TMP->(DbSkip())
	EndDo

	IF Select("TMP") > 0
		TMP->(DbCloseArea())
	EndIf
	//Tela com os palletes

	DEFINE MSDIALOG oDlg TITLE "Paletes em aberto" FROM 0,0 TO 250,500 PIXEL
	@ 32,4 LISTBOX oLbx1 FIELDS HEADER "","Romaneio","Palete" SIZE 248,75 OF oDlg PIXEL ON dblClick(fnMarca(aDados))
	oLbx1:SetArray(aDados)
	oLbx1:bLine:={|| {Iif(aDados[oLbx1:nAt,1],oOk,oNo),aDados[oLbx1:nAt,2],aDados[oLbx1:nAt,3]}}
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| Confirm(aDados,cOpera),oDlg:End()},{|| oDlg:End()},,@aButtons)
Else
	Aviso("Reabrir palete","Não existe palete para ser reaberto neste embarque.",{"OK"},1)
EndIF
IF Select("TMP") > 0
	TMP->(DbCloseArea())
EndIf
RestArea(_aArea)
Return
//-------------------------------------------------------------------------------------------------------------------------
//
Static Function fnMarca(aDados)

Local _nSoma := 1
Local _lMarcado := aDados[oLbx1:nAt,1]
If !_lMarcado
	for _i:= 1 to len(aDados)
		_nSoma+= if(aDados[_i,1],1,0)
	next
	If _nSoma > 1
		Aviso("Reabrir palete","Permitido a reabertura de apenas 1 palete por Operador.",{"OK"},1)
		Return
	Endif
Endif
aDados[oLbx1:nAt,1] := !aDados[oLbx1:nAt,1]
Return
//-------------------------------------------------------------------------------------------------------------------------------
//
Static Function Confirm(aDados,cOpera)

Local cOpera
Local cQuery := ""
Local nX
For nX := 1 to Len(aDados)
	IF aDados[nX][1]
		cQuery := " UPDATE " + RetSqlName("ZZL") + " SET ZZL_DTFECH = ' ', ZZL_HRFECH = ' '"
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND ZZL_FILIAL = '"+xFilial("ZZL")+"' "
		cQuery += " AND ZZL_OPER = '"+cOpera+"' "
		cQuery += " AND ZZL_EMBARQ = '"+aDados[nX][2]+"' "
		cQuery += " AND ZZL_PALETE = '"+aDados[nX][3]+"' "
		nErrQry := TCSqlExec( cQuery )
	Endif
Next nX
Return

//----------------------------------------------------------
Static Function Filtro()
//----------------------------------------------------------
Local cFiltro := ""
cFiltro := " DCW_EMBARQ >= '"+MV_PAR01+"' AND DCW_EMBARQ <= '"+MV_PAR02+"'"
cFiltro += " AND DCW_DATGER >= '"+DTOS(MV_PAR03)+"' AND DCW_DATGER <= '"+DTOS(MV_PAR04)+"'"
Return cFiltro
//---------------------------------------------------------------------------------------------------------------------
//
Static Function SelFiltro(lPergunte)
Local nPos := oBrwDCW:At()
Local lRefresh := .T.

Pergunte('WMSA320',lPergunte)
lRefresh := (MV_PAR05 < 4)

If lPergunte
	oBrwDCW:SetFilterDefault("@"+Filtro())
	If !lRefresh
		oBrwDCW:Refresh()
	EndIf
EndIf

If lRefresh
	If MV_PAR05 == 1
		oBrwDCW:Refresh(.T.)
	ElseIf MV_PAR05 == 2
		oBrwDCW:Refresh(.F.)
		oBrwDCW:GoBottom()
	Else
		oBrwDCW:Refresh(.F.)
		oBrwDCW:GoTo(nPos)
	EndIf
EndIf
Return .T.