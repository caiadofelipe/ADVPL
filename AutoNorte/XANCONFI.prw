#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

#DEFINE WMSA32001 "WMSA32001"
#DEFINE WMSA32002 "WMSA32002"
#DEFINE WMSA32003 "WMSA32003"
#DEFINE WMSA32004 "WMSA32004"
#DEFINE WMSA32005 "WMSA32005"
#DEFINE WMSA32006 "WMSA32006"
#DEFINE WMSA32007 "WMSA32007"
#DEFINE WMSA32008 "WMSA32008"
#DEFINE WMSA32009 "WMSA32009"
#DEFINE WMSA32010 "WMSA32010"
#DEFINE WMSA32011 "WMSA32011"
#DEFINE WMSA32012 "WMSA32012"
#DEFINE WMSA32013 "WMSA32013"
#DEFINE WMSA32014 "WMSA32014"
#DEFINE WMSA32015 "WMSA32015"
#DEFINE WMSA32016 "WMSA32016"
#DEFINE WMSA32017 "WMSA32017"
#DEFINE WMSA32018 "WMSA32018"
#DEFINE WMSA32019 "WMSA32019"
#DEFINE WMSA32020 "WMSA32020"
#DEFINE WMSA32021 "WMSA32021"
#DEFINE WMSA32022 "WMSA32022"
#DEFINE WMSA32023 "WMSA32023"
#DEFINE WMSA32024 "WMSA32024"
#DEFINE WMSA32025 "WMSA32025"
#DEFINE WMSA32026 "WMSA32026"
#DEFINE WMSA32027 "WMSA32027"
#DEFINE WMSA32028 "WMSA32028"
#DEFINE WMSA32029 "WMSA32029"
#DEFINE WMSA32030 "WMSA32030"

#DEFINE WMSA32083 "WMSA32083"
#DEFINE WMSA32084 "WMSA32084"
#DEFINE WMSA32085 "WMSA32085"
#DEFINE WMSA32086 "WMSA32086"
#DEFINE WMSA32087 "WMSA32087"
#DEFINE WMSA32088 "WMSA32088"
#DEFINE WMSA32089 "WMSA32089"
#DEFINE WMSA32090 "WMSA32090"
#DEFINE WMSA32091 "WMSA32091"
#DEFINE WMSA32092 "WMSA32092"
#DEFINE WMSA32093 "WMSA32093"
#DEFINE WMSA32094 "WMSA32094"
#DEFINE WMSA32095 "WMSA32095"
#DEFINE WMSA32096 ""
#DEFINE WMSA32097 ""
#DEFINE WMSA32098 "WMSA32098"

Static __lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Static __lAutoma := .T.
Static cAliasTmp := GetNextAlias()
Static oBrwTRB   := Nil
Static oTabTmp   := Nil

User Function XANCONFI(nOpcao)

//Verifica se há paletes conferidos pelo operador e que ainda não foram finalizados
Local _aArea := GetArea()
Local cQuery := ""
Local aButtons := {}
Local _nRecAb := 0
Local lZona
Private aDados := {}
Private oDlg
Private oDlgx
Private oLbx1
Private oLbx2
Private oOk		:= LoadBitmap( GetResources(), "CHECKED" )
Private oNo		:= LoadBitmap( GetResources(), "UNCHECKED" )
Private cEmbConf := ""
Private cPalConf := ""
Private cOpera := ""
IF nOpcao == 1
	AAdd(aButtons, { "ENCERRAR" ,{||U_xFimPale()}, "Encerrar"} )
Endif

If DCW->DCW_SITEMB $ "6/7"
	Help( NIL, NIL, "ANRECFEC", NIL, "Conferencia Finalizada", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Conferencia já finalizada."})
	Return
Endif

DbSelectArea("DCD")
DCD->(DbSetOrder(1))
IF DCD->(MsSeek(xFilial("DCD") + RetCodUsr()))
	cOpera := DCD->DCD_CODFUN
Else
	//		Help( Nil, Nil, , Nil, "Usuário não é operador", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Cadastrar usuário como operador."})
	Help( NIL, NIL, "ANLTOTVS", NIL, "Usuário não é operador", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Cadastrar usuário como operador."})
	Return
Endif

If Empty(DCW->DCW_XSEPAR)
	lZona := ApMsgYesNo("A conferência será paletizada por SETOR?")
	RecLock("DCW",.F.)
	Replace DCW_XSEPAR with IIF(lZona, "S", "N")
	MsUnLock()
Endif

IF PalAbert(DCW->DCW_EMBARQ, @_nRecAb)
	dbSelectArea("ZZL")
	cPalConf := ZZL->ZZL_PALETE
	dbGoto(_nRecAb)
	Confirm(2,DCW->DCW_EMBARQ,cPalConf,1)
Else
	//Executa a conferência do embarque posicionado
	Confirm(3,DCW->DCW_EMBARQ,"",nOpcao)
EndIF
RestArea(_aArea)
Return
//---------------------------------------------------------------------------------------------------
Static Function Tcl_Atl(_cParam, cEmbarq,nOpcao)

Local bOk
Local bCancel
If _cParam == "0"
	bOk		:= {|| _lPergEsc := .F.,IIF(nOpcao == 1,xSalva(cEmbarq),oDlgF:End()), oDlgF:End()}
	bCancel	:= {|| IIF(ApMsgYesNo("Deseja cancelar a conferencia, os dados não serão gravados?"), F_Sair(),"") }
	SetKey( VK_F6  , { || oBrwTRB:SetFocus() } )
	SetKey( VK_F7  , { || oGet1:SetFocus() } )
	SetKey( VK_F8  , bOk )
	SetKey( VK_F9  , bCancel )
Else
	SetKey( VK_F8, NIL )
	SetKey( VK_F6, NIL )
	SetKey( VK_F7, NIL )
	SetKey( VK_F9, NIL )
Endif
Return

//---------------------------------------------------------------------------------------------------
Static Function fnMarca1()

Local xA
For xA := 1 to Len(aDados)
	IF aDados[xA][1] .and. xA <> oLbx1:nAt
		MsgInfo("Já existe registro selecionado!")
		Return
	EndIf
Next
cEmbConf := aDados[oLbx1:nAt][2]
cPalConf := aDados[oLbx1:nAt][3]
aDados[oLbx1:nAt,1] := !aDados[oLbx1:nAt,1]
Return

Static Function Confirm(nOpc,cEmbarq,cPalete,nOpcao)
/*
nOpc
2 -> Quando houver palete em aberto
3 -> Quando não houver palete em aberto
*/
Private lFim := .F.
IF Empty(cEmbarq) .and. nOpcao == 1
	Aviso("Conferir","Nenhuma carga foi selecionada!",{"OK"},1)
	Return
Endif
Processa({|lFim| U_XCONFERE(nOpc,cEmbarq,cPalete,nOpcao) },"Aguarde...","Carregando romaneios...")
Return
//---------------------------------------------------------------------------------------------------------------------------------
//
User Function XCONFERE(nOpc,cEmbarq,cPalete,nOpcao)

Local nOpcA      := 0
Local aBrowse    := {}
Local aStruTMP   := {}
Local cArquivo   := ""
Local cEmbarque := ""
Local cPrdOri  :=  ""
Local cLoteCtl :=  ""
Local cNumLote :=  ""
Local lEstorna := .F.
Local nPosProd := 0
Local nPosLote := 0
Local nPosNumL := 0
Local nPosQtd  := 0
Local nPosUM   := 0
Local nPosZon  := 0
Local nPosDZon := 0
Local nPosPale := 0
Local nPosRec  := 0
Local cQuery   := ""
Local _nRecAb  := 0
Local bOk		:= {|| _lPergEsc := .F.,IIF(nOpcao == 1,xSalva(cEmbarq),oDlgF:End()), oDlgF:End()}
Local bCancel	:= {|| IIF(ApMsgYesNo("Deseja cancelar a conferencia, os dados não serão gravados?"), F_Sair(),"") }
Local aButtons := {}
Local aColsSX3    := {}
Local aArqTmp   := {}
Local aIndex	:= {}
Local aColumns	:= {}
Local aArqTab     := {}
Local aFields     := {}
Local oTipo,oChk0,oDlg
Local lVar0 := IIF(DCW->DCW_XSEPAR == "S", .T.,.F.)

//Local oFont:= TFont():New("Arial",,16,.T.)

DEFINE FONT oFont NAME "Arial" SIZE 0, -20 BOLD
DEFINE FONT oSBold NAME "Arial" SIZE 0, -12

Private nQuant   :=  1
Private cBarra	 := Space(TamSx3("B1_CODBAR")[1])
Private cProd	 := Space(TamSx3("B1_COD")[1])
Private cCodRef	 := Space(TamSx3("B1_XREFER")[1])
Private oDlgF
Private oSelect
Private oGet1
Private oGet2
Private oGet3
Private oGet4
Private lFinaliza :=  .F.
Private cCodZonAnt := ""
Private _lPergEsc := .T.

Aadd( aIndex, "TMP_ORDER+TMP_ITEM")
Aadd( aIndex, "TMP_PROD" )
Aadd( aIndex, "TMP_ITEM" )
Aadd( aIndex, "TMP_CODZON" )

AAdd(aArqTmp,{"TMP_ITEM" 	,BuscarSX3("ZCZ_ITEM"   , ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_PROD" 	,BuscarSX3("ZCZ_PROD"	, ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_DESC"	,BuscarSX3("B1_DESC"	, ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_LOTE"	,BuscarSX3("ZCZ_LOTE"	, ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_SUBLOT" 	,BuscarSX3("ZCZ_SUBLOT"	, ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_QTCONF" 	,BuscarSX3("ZCZ_QTCONF" , ,aColsSX3),"N",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_LOCALI"	,BuscarSX3("BE_LOCALIZ"	, ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_DESZON"  ,BuscarSX3("DC4_DESZON"	, ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_EMBARQ"	,BuscarSX3("ZCZ_EMBARQ" , ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_OPER" 	,BuscarSX3("ZCZ_OPER"  	, ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_UM"		,BuscarSX3("B1_UM"		, ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_CODZON"	,BuscarSX3("B5_XCODZON"  , ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_PRDORI" 	,BuscarSX3("ZCZ_PRDORI" , ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_LOCAL"	,BuscarSX3("ZCZ_LOCAL"	, ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_PALETE"	,BuscarSX3("ZCZ_XPALET" , ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
AAdd(aArqTmp,{"TMP_ORDER"	,"ORDER", "C" ,2					,0, " "})
AAdd(aArqTmp,{"TMP_RECNO"	,"RECNOZCZ", "N" ,10				,0, " "})

For nX := 1 To Len(aArqTmp)
	If	!aArqTmp[nX][1] $ "TMP_ORDER/TMP_LOTE/TMP_SUBLOT/TMP_PRDORI/TMP_RECNO/"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:lAutosize:=.t.
		If aArqTmp[nX][1] == "TMP_ITEM"
			aColumns[Len(aColumns)]:lAutosize:=.f.
			aColumns[Len(aColumns)]:SetSize(50)
		ElseIf aArqTmp[nX][1] == "TMP_PROD"
			aColumns[Len(aColumns)]:lAutosize:=.f.
			aColumns[Len(aColumns)]:SetSize(150)
		ElseIf aArqTmp[nX][1] == "TMP_DESC"
			aColumns[Len(aColumns)]:lAutosize:=.f.
			aColumns[Len(aColumns)]:SetSize(200)
		Else
			aColumns[Len(aColumns)]:SetSize(aArqTmp[nX][4])
		Endif
		aColumns[Len(aColumns)]:SetData( &("{||"+aArqTmp[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(aArqTmp[nX][2])
		aColumns[Len(aColumns)]:SetType(aArqTmp[nX][3])
		aColumns[Len(aColumns)]:SetDecimal(aArqTmp[nX][5])
		aColumns[Len(aColumns)]:SetPicture(aArqTmp[nX][6])
	Endif
	AAdd(aArqTab,{aArqTmp[nX][1],aArqTmp[nX][3],aArqTmp[nX][4],aArqTmp[nX][5]})
	AAdd(aFields,{aArqTmp[nX][1],aArqTmp[nX][2],aArqTmp[nX][3],aArqTmp[nX][4],aArqTmp[nX][5],aArqTmp[nX][6]})
Next nX

CriaTabTmp(aArqTab,aIndex,cAliasTmp,@oTabTmp)

IF !PalAbert(cEmbarq, @_nRecAb)
	dbSelectArea(cAliasTmp)
	RecLock(cAliasTmp,.T.)
	Replace TMP_ITEM 	with " "
	MsUnLock()
Else
	//	//Selececiona conferência que ainda não foi finalizada
	cQuery := " SELECT ZCZ.* , ZCZ.R_E_C_N_O_ RECNOZCZ "
	cQuery += " FROM " + RetSqlName("ZCZ") + " ZCZ, " + RetSqlName("ZZL") + " ZZL "
	cQuery += " WHERE ZCZ.D_E_L_E_T_ = ' ' "
	cQuery += " AND ZCZ_FILIAL = '"+xFilial("ZCZ")+"' "
	cQuery += " AND ZCZ_EMBARQ = '"+cEmbarq+"'"
	cQuery += " AND ZCZ_OPER = '"+cOpera+"' "
	cQuery += " AND ZZL_FILIAL = '"+xFilial("ZZL")+"' "
	cQuery += " AND ZCZ_EMBARQ = ZZL_EMBARQ"
	cQuery += " AND ZCZ_XPALET = ZZL_PALETE"
	cQuery += " AND ZZL_OPER = '"+cOpera+"' "
	cQuery += " AND ZZL_DTFECH = '        '"
	cQuery += " AND ZZL.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZCZ_EMBARQ, ZCZ_XPALET, ZCZ_ITEM, ZCZ_PROD"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"XZCZ",.F.,.F.)
	DbSelectArea("XZCZ")
	XZCZ->(DbGoTop())
	IF !XZCZ->(EOf())
		While !XZCZ->(Eof())
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1") + XZCZ->ZCZ_PROD))
			SZ8->(dbSetOrder(1))
			SZ8->(MsSeek(xFilial("SZ8") + XZCZ->ZCZ_PROD + XZCZ->ZCZ_LOCAL))
			DbSelectArea("SB5")
			SB5->(DbSetOrder(1))
			SB5->(MsSeek(xFilial("SB5") + SB1->B1_COD ))
			DbSelectArea("DC4")
			DC4->(DbSetOrder(1))
			DC4->(MsSeek(xFilial("DC4") + XZCZ->ZCZ_CODZON))
			dbSelectArea(cAliasTmp)
			RecLock(cAliasTmp,.T.)
			Replace TMP_ITEM 	with XZCZ->ZCZ_ITEM,;
			TMP_EMBARQ	with XZCZ->ZCZ_EMBARQ,;
			TMP_OPER	with XZCZ->ZCZ_OPER,;
			TMP_PROD	with XZCZ->ZCZ_PROD,;
			TMP_DESC	with SB1->B1_DESC,;
			TMP_LOTE	with XZCZ->ZCZ_LOTE,;
			TMP_SUBLOT	with XZCZ->ZCZ_SUBLOT,;
			TMP_QTCONF	with XZCZ->ZCZ_QTCONF,;
			TMP_UM		with SB1->B1_UM,;
			TMP_LOCALI	with IIF(!Empty(XZCZ->ZCZ_CODZON), XZCZ->ZCZ_CODZON, "----  SEM LOCAL  ----"),;
			TMP_CODZON	with XZCZ->ZCZ_CODZON,;
			TMP_DESZON	with DC4->DC4_DESZON,;
			TMP_PRDORI	with XZCZ->ZCZ_PRDORI,;
			TMP_LOCAL	with XZCZ->ZCZ_LOCAL,;
			TMP_PALETE	with XZCZ->ZCZ_XPALET,;
			TMP_ORDER 	with "ZZ",;
			TMP_RECNO	with XZCZ->RECNOZCZ
			XZCZ->(DbSkip())
		EndDo
	Else
		dbSelectArea(cAliasTmp)
		RecLock(cAliasTmp,.T.)
		Replace TMP_ITEM 	with " "
		MsUnLock()
	Endif
	XZCZ->(DbCloseArea())
EndIf
dbSelectArea(cAliasTmp)
dbSetOrder(1)
dbGotop()

Tcl_Atl("0", cEmbarq,nOpcao)

oSize := FwDefSize():New(.T.)
oSize:lLateral := .F.
oSize:lProp	:= .T. // Proporcional
oSize:AddObject( "CABECALHO",  100, 20, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "GETDADOS" ,  100, 75, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "RODAPE"   ,  100, 05, .T., .T. ) // Totalmente dimensionavel
oSize:lProp 	:= .T. // Proporcional
oSize:Process() 	   // Dispara os calculos

nLinIni := oSize:GetDimension("CABECALHO","LININI")
nLinEnd := oSize:GetDimension("CABECALHO","LINEND")
nGd1 := oSize:GetDimension("GETDADOS","LININI")
nGd2 := oSize:GetDimension("GETDADOS","COLINI")
nGd5 := oSize:GetDimension("RODAPE","LININI")
nGd6 := oSize:GetDimension("RODAPE","COLINI")
nGd3 := oSize:GetDimension("GETDADOS","LINEND") - 100
nGd4 := oSize:GetDimension("GETDADOS","COLEND")

cCadastro := "Conferência Romaneio: " + cEmbarq
If lVar0
	cMens	  := "Divisão do Palete por Setor"
Else
	cMens	  := "Palete NÃO Setorizado"
Endif
DEFINE MSDIALOG oDlgF TITLE "Conferência Romaneio: " + cEmbarq From oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

IF nOpcao == 1

	@ nLinIni,010 SAY "Quantidade"	FONT oFont SIZE 120, 12 OF oDlgF PIXEL
	@ nLinIni,070 MSGET oGet1 VAR nQuant FONT oFont PICTURE "999999" Valid NaoVazio() .and. Positivo() SIZE 60, 12 OF oDlgF PIXEL

	@ nLinIni,260 MSGET oGet5 VAR cMens FONT oFont SIZE 150, 12 OF oDlgF PIXEL When .F.
//	@ nLinIni + 5 ,260 CHECKBOX oChk0 VAR lVar0 PROMPT OemToAnsi("Palete por Setor") FONT oFont SIZE 120, 20 OF oDlgF PIXEL When .F.

	@ nLinIni+025,010 SAY "Código de Barras" FONT oFont SIZE 120, 12 OF oDlgF PIXEL
	@ nLinIni+040,010 MSGET oGet2	 VAR cBarra FONT oFont Valid U_GravaDados(1,cEmbarq,cBarra,cPalete,@nQuant) .or. Vazio() SIZE 120, 12 OF oDlgF PIXEL

	@ nLinIni+025,260 SAY "Código Referência" FONT oFont SIZE 120, 12 OF oDlgF PIXEL
	@ nLinIni+040,260 MSGET oGet3 VAR cCodRef	FONT oFont Picture "@!" Valid U_GravaDados(2,cEmbarq,cCodRef,cPalete,@nQuant) .or. Vazio() SIZE 120, 12 OF oDlgF PIXEL

	@ nLinIni+025,460 SAY "Produto" FONT oFont SIZE 120, 12 OF oDlgF PIXEL
	@ nLinIni+040,460 MSGET oGet4   VAR cProd FONT oFont Valid U_GravaDados(3,cEmbarq,cProd,cPalete,@nQuant) .or. Vazio() F3 "SB1" SIZE 120, 12 OF oDlgF PIXEL

	@ nGd5 ,nGd6 SAY "Teclas de Atalho:   F6 - Foco no Grid         F7 - Foco na Quantidade         F8 - Confirmar       F9 - Cancelar" FONT oSBold Of oDlgF PIXEL SIZE 600 ,9

Endif
oPanel := TPanel():New(nGd1,nGd2,'',oDlgF,, .T., .T.,, ,nGd4,nGd3,.T.,.T. )
oBrwTRB := FWMBrowse():New()
oBrwTRB:SetOwner(oPanel)
oBrwTRB:SetTemporary(.T.)
oBrwTRB:SetAlias(cAliasTmp)
oBrwTRB:SetColumns(aColumns)
oBrwTRB:SetMenuDef('XANCONFI')
oBrwTRB:SetProfileID('TMP')
oBrwTRB:SetDescription("")
oBrwTRB:SetFieldFilter( aFields )
oBrwTRB:SetUseFilter()
oBrwTRB:DisableDetails()
oBrwTRB:DisableReport()
oBrwTRB:SetAmbiente(.F.)
oBrwTRB:SetWalkThru(.F.)
oBrwTRB:SetFixedBrowse(.T.)
oBrwTRB:SetDoubleClick( {|| MudaQtde()} )
oBrwTRB:Activate()
Activate MsDialog oDlgF On Init (EnchoiceBar(oDlgF,bOk,bCancel,,aButtons), oGet1:SetFocus()) Centered VALID CFPrEsc()
DelTabTmp(cAliasTmp,oTabTmp)
Tcl_Atl("1")

Return
//----------------------------------------------------------------------------------------------
Static Function F_Sair

_lPergEsc := .F.
oDlgF:End()
Return

//----------------------------------------------------------------------------------------------
Static Function CFPrEsc

Local lRet := .T.
If _lPergEsc
	lRet := MsgYesNo("Confirma saida da tela da Conferencia?","Atenção")
Endif
Return lRet


/*/{Protheus.doc} MudaQtde
Muda a Quantidade
@author felipe.caiado
@since 12/03/2019
@version 1.0

@type function
/*/
Static Function MudaQtde()

Local aRet as array
Local aPerg as array

aRet 	:= {}
aPerg	:= {}

aAdd( aPerg ,{1,Alltrim("Nova Quantidade"),0.00,"@E 9,999.99",".T.","","",40,.T.})

If !ParamBox(aPerg ,"Alterar Quantidade",@aRet)
	Return(.F.)
Else

	RecLock(cAliasTmp,.F.)
	Replace TMP_QTCONF with MV_PAR01
	(cAliasTmp)->(MsUnLock())

EndIf

Pergunte("WMSA320",.F.)

Return()
//---------------------------------------------------------------------------------------------------------------

Static Function MenuDef()

Private aRotina := {}

ADD OPTION aRotina TITLE 'Excluir'    ACTION 'u_Delok()'	OPERATION 5 ACCESS 0

Return aRotina

//-----------------------------------------------------------------------------------------------------------------------------------------

Static Function xSalva(cEmbarq)

Local _aArea 	:= GetArea()
Local cPalete	:= CriaVar("ZZL_PALETE",.F.)
Local _nRecAb	:= 0
Local _nTotIt	:= 0
Local lZona		:= .F.
Local lPalete	:= .F.
Local _aSetor	:= {}
Local lFinaliza := .F.
Local lFinalZona:= .F.
Local _lGeraZZL := .F.
Local lRefItem	:= .F.
Local _nVez		:= 1
Local _aPaltFec	:= {}

Tcl_Atl("1")

dbSelectArea(cAliastmp)
dbGotop()
If !Eof() .and. !Empty((cAliastmp)->TMP_PROD) .and. (cAliastmp)->TMP_QTCONF > 0
	lZona := IIF(DCW->DCW_XSEPAR == "S",.T.,.F.)
	IF ApMsgYesNo("Deseja finalizar conferência?")
		lFinaliza := .T.
	Endif
	dbSelectArea(cAliastmp)
	(cAliastmp)->(DbSetOrder(4))
	dbGotop()
	If lFinaliza .and. lZona
		_aSetor := CriaTMPZ()
		If Len(_aSetor) == 0
			lFinaliza := .F.
			MsgInfo("Palete não será finalizado, pois não foram selecionados Setores para Finalizar")
		Endif
	Else
		lFinalZona := .T.
	Endif

//Aadd( aIndex, "TMP_EMBARQ+TMP_OPER+TMP_CODZON+TMP_PALET" )

	While !(cAliastmp)->(Eof())
		cCodZona := (cAliastmp)->TMP_CODZON
		cPalete := ""
		IF !PalAbert(cEmbarq, @_nRecAb)
			RecLock("ZZL",.T.)
			ZZL_FILIAL      := xFilial("ZZL")
			ZZL->ZZL_EMBARQ := cEmbarq
			ZZL->ZZL_OPER   := __cUserID
			ZZL->ZZL_DTINI  := dDataBase
			ZZL->ZZL_HRINI  := Time()
			ZZL->(MsUnlock())
		Else
			dbSelectArea("ZZL")
			dbGoto(_nRecAb)
			cPalete := ZZL->ZZL_PALETE
		Endif
		If lFinaliza
			If lZona
				If ascan(_aSetor, (cAliastmp)->TMP_CODZON) == 0
					lFinalZona := .F.
					_lGeraZZL  := .T.
				Else
					lFinalZona := .T.
					GeraPalete(cEmbarq, @cPalete)
				Endif
			ElseIf _nVez == 1
				GeraPalete(cEmbarq, @cPalete)
				_nVez++
			Endif
		Endif
		While !(cAliastmp)->(Eof()) .and. cCodZona == (cAliastmp)->TMP_CODZON
			cProduto := cPrdOri  := (cAliastmp)->TMP_PROD
			cLoteCtl := (cAliastmp)->TMP_LOTE
			cNumLote := (cAliastmp)->TMP_SUBLOT
			nQuant   := (cAliastmp)->TMP_QTCONF
			cLocal   := (cAliastmp)->TMP_LOCAL
			nRecno	 := (cAliastmp)->TMP_RECNO
			_cItem	 := (cAliastmp)->TMP_ITEM
			_cOperador:= (cAliastmp)->TMP_OPER
			_cCodZon  := (cAliastmp)->TMP_CODZON
			_cLocaliz := (cAliastmp)->TMP_LOCALI
			_nTotIt	 := 0
			IF !Empty(cProduto) .and. nQuant > 0
				If nRecno > 0
					dbSelectArea("ZCZ")
					dbGoto(nRecno)
					If QtdComp(nQuant) <> QtdComp(ZCZ->ZCZ_QTCONF)
						u_ExclConf(.T., cEmbarq,_cOperador,cProduto,cProduto,cLoteCtl,cNumLote, ZCZ->ZCZ_QTCONF, nRecno)
						u_GravCofOpe(_cItem, cEmbarq,__cUserID,cPrdOri,cProduto,cLoteCtl,cNumLote,nQuant,.F.,cPalete,cLocal, _cCodZon, _cLocaliz)
					Else
						IF lFinaliza .and. lFinalZona
							RecLock("ZCZ",.F.)
							Replace ZCZ->ZCZ_XPALET with cPalete
							MsUnLock()
						Endif
					Endif
				Else
					u_GravCofOpe(_cItem, cEmbarq,__cUserID,cPrdOri,cProduto,cLoteCtl,cNumLote,nQuant,.F.,cPalete,cLocal, _cCodZon, _cLocaliz)
				Endif
				_nTotIt++
			EndIf
			(cAliastmp)->(dbSkip())
		End
		If lFinaliza .and. !Empty(cPalete)
			If ascan(_aPaltFec, cPalete) == 0
				aadd(_aPaltFec, cPalete)
			Endif
		Endif
	End
	If Len(_aPaltFec) > 0
		For nH:=1 to Len(_aPaltFec)
			dbSelectArea("ZZL")
			dbSetOrder(2)
			If dbSeek(xFilial()+cEmbarq+cOpera+_aPaltFec[nH])
				RecLock("ZZL",.F.)
				Replace ZZL_QTDITE with _nTotIt
				MsUnLock()
			Endif
			// Refaz o Item do palete
			lRefItem := .T.
			_cItem := Replicate("0",Len((cAliastmp)->TMP_ITEM))
			dbSelectArea("ZCZ")
			dbSetOrder(5)
			dbSeek(xFilial()+cEmbarq+__cUserID+_aPaltFec[nH])
			While !Eof() .and. xFilial()+cEmbarq+__cUserID+_aPaltFec[nH] == ZCZ->(ZCZ_FILIAL+ZCZ_EMBARQ+ZCZ_OPER+ZCZ_XPALET)
				_cItem := Soma1(_cItem)
				dbSelectArea("ZCZ")
				RecLock("ZCZ",.F.)
				Replace ZCZ_ITEM with _cItem
				MsUnLock()
				dbSkip()
			End
			u_RCONFREC("1",dDataBase, cEmbarq, _aPaltFec[nH])
		Next
	Endif
	If lRefItem
		_cItem := Replicate("0",Len((cAliastmp)->TMP_ITEM))
		_cPalAbert := CriaVar("ZCZ_XPALET",.F.)
		dbSelectArea("ZCZ")
		dbSetOrder(5)
		dbSeek(xFilial()+cEmbarq+__cUserID+_cPalAbert)
		While !Eof() .and. xFilial()+cEmbarq+__cUserID+_cPalAbert == ZCZ->(ZCZ_FILIAL+ZCZ_EMBARQ+ZCZ_OPER+ZCZ_XPALET)
			_cItem := Soma1(_cItem)
			dbSelectArea("ZCZ")
			RecLock("ZCZ",.F.)
			Replace ZCZ_ITEM with _cItem
			MsUnLock()
			dbSkip()
		End
	Endif
	If lZona
		If lFinaliza .and. _lGeraZZL
			IF !PalAbert(cEmbarq, @_nRecAb)
				RecLock("ZZL",.T.)
				ZZL_FILIAL      := xFilial("ZZL")
				ZZL->ZZL_EMBARQ := cEmbarq
				ZZL->ZZL_OPER   := __cUserID
				ZZL->ZZL_DTINI  := dDataBase
				ZZL->ZZL_HRINI  := Time()
				ZZL->(MsUnlock())
			Endif
		Endif
	Endif

Endif
Tcl_Atl("0", cEmbarq,1)
RestArea(_aArea)
Return
//----------------------------------------------------------------------------------------
//
Static Function CriaTMPZ()

Local _aArea := GetArea()
Local aStru	 := {}
Local cArqTrab	:= GetNextAlias()
Local oMrkBrowse:= FWMarkBrowse():New()
Local _oTMPZ
Local aColumns	:= {}
Local bok    :={|| lRetorno:=.T.,oDlgAB:End()}
Local bCancel:={|| lRetorno:=.F.,oDlgAB:End()}
Local _aSetor := {}
Local _nTotSet := 0
Local lMarcar    := .F.
Aadd(aStru, {"TRB_OK"		,"C",2						,0					, "OK"})
Aadd(aStru, {"TRB_ZONA"		,"C",6						,0					, "Codigo"})
Aadd(aStru, {"TRB_DESC"		,"C",TAMSX3("DC4_DESZON")[1],0					, "Descrição Setor"})

If _oTMPZ <> Nil
	_oTMPZ:Delete()
	_oTMPZ:= Nil
EndIf
//Cria o Objeto do FwTemporaryTable
_oTMPZ := FwTemporaryTable():New(cArqTrab)
//Cria a estrutura do alias temporario
_oTMPZ:SetFields(aStru)
//Adiciona o indicie na tabela temporaria
_oTMPZ:AddIndex("1",{"TRB_ZONA"})
//Criando a Tabela Temporaria
_oTMPZ:Create()

dbSelectArea(cAliastmp)
(cAliastmp)->(DbSetOrder(4))
dbGotop()
While !Eof()
	_cZona := (cAliastmp)->TMP_CODZON
	_cDescZ := Posicione("DC4",1,xFilial("DC4")+_cZona,"DC4_DESZON")
	_nTotSet++
	dbSelectArea(cArqTrab)
	RecLock(cArqTrab,.T.)
	Replace TRB_ZONA with _cZona,;
			TRB_DESC with _cDescZ
	MsUnLock()
	dbSelectArea(cAliastmp)
	While !Eof() .and. _cZona == (cAliastmp)->TMP_CODZON
		dbSkip()
	End
End
If _nTotSet > 1
	For nX := 1 To Len(aStru)
		If	!aStru[nX][1] $ "TRB_OK"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:lAutosize:=.T.
			aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(aStru[nX][5])
			//		aColumns[Len(aColumns)]:SetSize(aStru[nX][6])
			aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
			//		aColumns[Len(aColumns)]:SetPicture(aStru[nX][7])
			If aStru[nX][2] $ "N/D"
				aColumns[Len(aColumns)]:nAlign := 3
			Endif
		EndIf
	Next nX
	dbSelectArea(cArqTrab)
	dbGotop()
	aSize := MsAdvSize(,.F.,400)
	DEFINE MSDIALOG oDlgAB TITLE "Selecione Setor que deseja Finalizar" From 300,0 to 800,1000 OF oMainWnd PIXEL
	oMrkBrowse:= FWMarkBrowse():New()
	oMrkBrowse:SetFieldMark("TRB_OK")
	oMrkBrowse:SetOwner(oDlgAB)
	oMrkBrowse:SetAlias(cArqTrab)
	oMrkBrowse:bAllMark := {|| SetMarkAll(oMrkBrowse:Mark(),lMarcar := !lMarcar, cArqTrab),oMrkBrowse:Refresh(.T.)}
	oMrkBrowse:AddButton("Confirmar", bOk,,,, .F., 7 ) //Confirmar
	oMrkBrowse:AddButton("Cancelar" ,bCancel,,,, .F., 7 ) //Parâmetros
	oMrkBrowse:SetDescription("          Selecione o Setor para Finalizar")
	oMrkBrowse:SetColumns(aColumns)
	oMrkBrowse:SetMenuDef("")
	oMrkBrowse:Activate()
	ACTIVATE MSDIALOg oDlgAB CENTERED
	If lRetorno
		dbSelectArea(cArqTrab)
		dbGotop()
		While !Eof()
			If !Empty((cArqTrab)->TRB_OK)
				aadd(_aSetor, (cArqTrab)->TRB_ZONA)
			Endif
			dbSkip()
		End
	Endif
	_oTMPZ:Delete()
	_oTMPZ:= Nil
Else
	dbSelectArea(cArqTrab)
	dbGotop()
	While !Eof()
		aadd(_aSetor, (cArqTrab)->TRB_ZONA)
		dbSkip()
	End
	dbSelectArea(cArqTrab)
	dbCloseArea()
Endif
RestArea(_aArea)
Return(_aSetor)

//--------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll
Função para marcar todas as requisições

@author Tiago Filipe da Silva
@since 08/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function SetMarkAll(cMarca,lMarcar, cArqTrab)

Local aArea  := (cArqTrab)->(GetArea())

dbSelectArea(cArqTrab)
(cArqTrab)->(dbGoTop())
While (cArqTrab)->(!Eof())
	RecLock((cArqTrab), .F.)
	(cArqTrab)->TRB_OK := IIf(lMarcar,cMarca,'')
	MsUnLock()
	(cArqTrab)->(dbSkip())
EndDo

RestArea(aArea)
Return .T.

//----------------------------------------------------------------------------------------
//

User Function ExclConf(_lDelZCZ, cEmbarq,_cOperador,cProduto,cProduto,cLoteCtl,cNumLote, nQtConf, nRecnoZ2)

Local _aArea := GetArea()
Local _aDCY 	:= {}
Local _nSaldo 	:= 0
Local _nTotDCY 	:= 0
Local _aAlmox	:= {}
Local nQuant := nQtConf
Local nY, nJ
dbSelectArea("DCY")
dbSetOrder(1)
If dbSeek(xFilial()+cEmbarq+cProduto+cProduto+cLoteCtl+cNumLote)	// O DCY pode ter no máximo 2 registros do mesmo produto
	While !Eof() .and. xFilial("DCY")+cEmbarq+cProduto+cProduto+cLoteCtl+cNumLote == DCY->(DCY_FILIAL+DCY_EMBARQ+DCY_PRDORI+DCY_PROD+DCY_LOTE+DCY_SUBLOT)
		_nTotDCY += DCY->DCY_QTCONF
		If DCY->DCY_QTORIG == DCY->DCY_QTCONF
			aadd(_aDCY,{"1", DCY->DCY_QTCONF, DCY->(recno())})
			_nPos := aScan(_aAlmox,{|x| x[2] == DCY->DCY_LOCAL  })
			If _nPos == 0
				aadd(_aAlmox,{ "1", DCY->DCY_LOCAL})
			Endif
		Else
			aadd(_aDCY,{"0", DCY->DCY_QTCONF, DCY->(recno())})
			_nPos := aScan(_aAlmox,{|x| x[2] == DCY->DCY_LOCAL  })
			If _nPos == 0
				aadd(_aAlmox, {"0", DCY->DCY_LOCAL})
			Endif
		Endif
		dbSkip()
	End
	If _nTotDCY >= nQuant
		If Len(_aDCY) > 1
			aSort(_aDCY,,,{|x,y| x[1] < y[1] })
			aSort(_aAlmox,,,{|x,y| x[1] < y[1] })
			For nJ:=1 to Len(_aDCY)
				nQuant := nQuant - _aDCY[nJ,2]
				dbSelectArea("DCY")
				dbGoto(_aDCY[nJ,3])
				If nQuant >= 0 .and. nj < Len(_aDCY)
					RecLock("DCY",.F.)
					dbDelete()
					MsUnLock()
				Else
					RecLock("DCY",.F.)
					Replace DCY->DCY_QTCONF with ABS(nQuant)
					MsUnLock()
				Endif
				If nQuant <= 0
					Exit
				Endif
			Next
		Else
			nQuant := nQuant - _aDCY[1,2]
			dbSelectArea("DCY")
			dbGoto(_aDCY[1,3])
			RecLock("DCY",.F.)
			Replace DCY->DCY_QTCONF with ABS(nQuant)
			MsUnLock()
		Endif
		_aDCZ    := {}
		_nSaldo  := 0
		_nTotDCZ := 0
		nQuant   := nQtConf
		For nY:=1 to Len(_aAlmox)
			dbSelectArea("DCZ")
			dbSetOrder(1)
			dbSeek(xFilial()+cEmbarq+_cOperador+cProduto+cProduto+cLoteCtl+cNumLote+_aAlmox[nY,2])
			While !Eof() .and. xFilial("DCZ")+cEmbarq+_cOperador+cProduto+cProduto+cLoteCtl+cNumLote+_aAlmox[nY,2] == DCZ->(DCZ_FILIAL+DCZ_EMBARQ+DCZ_OPER+DCZ_PRDORI+DCZ_PROD+DCZ_LOTE+DCZ_SUBLOT+DCZ_LOCAL)
				nQuant := nQuant - DCZ->DCZ_QTCONF
				If nQuant >= 0
					RecLock("DCZ",.F.)
					dbDelete()
					MsUnLock()
				Else
					RecLock("DCZ",.F.)
					Replace DCZ->DCZ_QTCONF with ABS(nQuant)
					MsUnLock()
				Endif
				If nQuant <= 0
					Exit
				Endif
				dbSkip()
			End
		Next
		If _lDelZCZ
			ZCZ->(DbGoTo(nRecnoZ2))
			RecLock('ZCZ',.F.)
			ZCZ->(DbDelete())
			ZCZ->(MsUnlock())
		Endif
	Endif
Else
	If nRecnoZ2 > 0
		ZCZ->(DbGoTo(nRecnoZ2))
		RecLock('ZCZ',.F.)
		ZCZ->(DbDelete())
		ZCZ->(MsUnlock())
	Endif
Endif
RestArea(_aArea)
Return


//------------------------------------------------------------------------------
//

Static Function GeraPalete(cEmbarq, cNum)

Local _aArea 	:= GetArea()
Local _lRet 	:= PrxPLock(cEmbarq)
Local nTam  	:= TamSx3("ZZL_PALETE")[1]
Local _cArqQry	:= GetNextAlias()
Local _cPalete 	:= CriaVar("ZZL_PALETE",.F.)
If _lRet
	If Empty(cNum)
		cQuery := " SELECT MAX(ZZL_PALETE) PALETE FROM " + RetSqlName("ZZL")
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND ZZL_FILIAL = '"+xFilial("ZZL")+"' "
		cQuery += " AND ZZL_EMBARQ = '"+cEmbarq+"' "
		cQuery := ChangeQuery(cQuery)
		IF Select("XPLT") > 0
			XPLT->(DbCloseArea())
		Endif
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"XPLT",.F.,.T.)
		IF !XPLT->(Eof())
			cNum := XPLT->PALETE
		Else
			cNum := Replicate("0",nTam)
		Endif
		XPLT->(DbCloseArea())
		cNum := Soma1(Subs(cNum,1,nTam))
	Else
		_cPalete := cNum
	Endif
	dbSelectArea("ZZL")
	ZZL->(dbSetOrder(2))
	If ZZL->(dbSeek(xFilial()+cEmbarq+cOpera+_cPalete))
		RecLock("ZZL",.F.)
		Replace ZZL_PALETE with cNum,;
				ZZL_DTFECH with dDataBase,;
				ZZL_HRFECH with Time()
		MsUnLock()
	Endif
	UnLockByName("P"+cEmbarq+AllTrim(cEmpAnt+cFilAnt),.T.,.T.)
Endif
RestArea(_aArea)
Return(_lRet)

//------------------------------------------------------------------------------
//

Static Function PalAbert(cEmbarq, _nRecZZL)

Local _aArea := GetArea()
Local _lRet  := .F.
dbSelectArea("ZZL")
ZZL->(dbSetOrder(2))
If ZZL->(dbSeek(xFilial()+cEmbarq+cOpera))
	While !ZZL->(Eof()) .and. xFilial("ZZL")+cEmbarq+cOpera == ZZL->(ZZL_FILIAL+ZZL_EMBARQ+ZZL_OPER)
		If Empty(ZZL->ZZL_DTFECH)
			_lRet := .T.
			_nRecZZL := recno()
			Exit
		Endif
		ZZL->(dbSkip())
	EndDo
EndIf
RestArea(_aArea)
Return(_lRet)
//-------------------------------------------------------------------------------
//
User Function DelOk()

Local lRet := .F.
Local _cItem := Replicate("0",TamSx3("ZCZ_ITEM")[1])
//Local _nLinha := oSelect:nAT
Local aNewCols := {}
Local _nRecno 	:= (cAliasTmp)->TMP_RECNO
Local _cProd	:= (cAliasTmp)->TMP_PROD
Local cEmbarque := (cAliasTmp)->TMP_EMBARQ
Local _nQuant 	:= (cAliasTmp)->TMP_QTCONF
Local _cLote 	:= (cAliasTmp)->TMP_LOTE
Local _cNumLote := (cAliasTmp)->TMP_SUBLOT
Local _cLocal	:= (cAliasTmp)->TMP_LOCAL
Local _cOperad	:= (cAliasTmp)->TMP_OPER
Local _cPalete	:= (cAliasTmp)->TMP_PALETE
Local _cItemPos := (cAliasTmp)->TMP_ITEM

If Empty((cAliasTmp)->TMP_ITEM)
	Return()
EndIf

IF ApMsgYesNo("Item será excluido do palete, confirma ?")
	If _nRecno > 0
		u_ExclConf(.T., cEmbarque,_cOperad,_cProd,_cProd,_cLote,_cNumLote, _nQuant, _nRecno)
	Endif
	dbSelectArea(cAliasTmp)
	RecLock((cAliasTmp),.F.)
	dbDelete()
	MsUnLock()
	dbSetOrder(3)
	dbGotop()
	If !Eof()
		While !Eof()
			If _cItemPos <> (cAliasTmp)->TMP_ITEM
				_cItem := Soma1(_cItem)
				_cItAnt := (cAliasTmp)->TMP_ITEM
				RecLock((cAliasTmp), .F.)
				Replace TMP_ITEM with _cItem
				MsUnLock()
				dbSelectArea("ZCZ")
				dbSetOrder(5)
				If dbSeek(xFilial()+(cAliasTmp)->TMP_EMBARQ+(cAliasTmp)->TMP_OPER+(cAliasTmp)->TMP_PALETE+_cItAnt+(cAliasTmp)->TMP_PROD)
					RecLock("ZCZ",.F.)
					Replace ZCZ_ITEM with _cItem
					MsUnLock()
				Endif
			Endif
			dbSelectArea(cAliasTmp)
			dbSkip()
		End
	Endif
	dbSelectArea(cAliasTmp)
	dbSetOrder(1)
	dbGotop()
Endif
oBrwTRB:Refresh(.T.)
Return lRet

//-------------------------------------------------------------------------------------------------------------------
//
User Function GravaDados(nOpcx,cEmbarq,cCampo,cPalete,nQuant)

Local lRet := .T.
Local nX := 0
Local lConferido := .F.
Local _cEnder  := CriaVar("Z8_ENDER",.F.)
Local cProdut
Local cDescpr
Local cCodBar
Local nOpca := 0
Local xA

Private aArPrd

DbSelectArea("SB1")

IF !Empty(cCampo)
	Do Case
		Case nOpcx == 1 //Código de Barras
			SB1->(DbSetOrder(5))
			IF !SB1->(MsSeek(xFilial("SB1") + Alltrim(cCampo)))
				MsgInfo("Produto não encontrado")
				Return .F.
			Else
				nRecSB1 := SB1->(Recno())
				cProdut := SB1->B1_COD
				cDescPr := SB1->B1_DESC
				cCodBar := SB1->B1_CODBAR

				//Verifica se existe mais de um código de barras igual (olha o próximo registro)
				SB1->(DbSkip())

				IF cCodBar == SB1->B1_CODBAR
					aArPrd := {{.F.,SB1->B1_COD,SB1->B1_DESC},{.F.,cProdut,cDescPr}}

					//Tela com os produtos
					DEFINE MSDIALOG oDlgX TITLE "Produtos" FROM 0,0 TO 250,500 PIXEL

					@ 60,5 LISTBOX oLbx2 FIELDS HEADER "","Produto","Descrição";
					SIZE 248,75 OF oDlgX PIXEL ON dblClick(fnMarca2())

					oLbx2:SetArray(aArPrd)
					oLbx2:bLine:={|| {Iif(aArPrd[oLbx2:nAt,1],oOk,oNo),aArPrd[oLbx2:nAt,2],aArPrd[oLbx2:nAt,3]}}

					ACTIVATE MSDIALOG oDlgX CENTER ON INIT EnchoiceBar(oDlgX,{|| nOpca := 1, oDlgX:End() },{|| nOpca := 2, oDlgX:End() },,)

					IF nOpca == 1
						For xA := 1 to Len(aArPrd)
							IF aArPrd[xA][1]
								SB1->(DbSetOrder(1))
								SB1->(MsSeek(xFilial("SB1") + Alltrim(aArPrd[xA][2])))
								lMarcado := .T.
								Exit
							Endif
						Next xA

						//Caso não tenha sido marcado nenhum, o sistema irá se posicionar no primeiro
						IF !lMarcado
							SB1->(MsSeek(xFilial("SB1") + Alltrim(aArPrd[1][2])))
						Endif
					Else
						Return .F.
					Endif
				Else
					SB1->(DbGoTo(nRecSB1))
				Endif
			Endif
		Case nOpcx == 2 //Código de Referência
			SB1->(DbOrderNickName("B1REFFOR"))
			IF !SB1->(MsSeek(xFilial("SB1") + Alltrim(cCampo)))
				MsgInfo("Produto não encontrado")
				Return.F.
			Endif
		Case nOpcx == 3 //Código do Produto
			SB1->(DbSetOrder(1))
			IF !SB1->(MsSeek(xFilial("SB1") + Alltrim(cCampo)))
				MsgInfo("Produto não encontrado")
				Return .F.
			Endif
	EndCase
	/*
	If SB1->B1_XEMBFOR > 0
	nQuant   := SB1->B1_XEMBFOR * nQuant
	Endif
	*/
	//Verifica se o produto faz parte da lista de itens do Aviso de Recebimento
	DbSelectArea("DCY")
	DCY->(DbSetOrder(1))
	IF !DCY->(MsSeek(xFilial("DCY") + cEmbarq + SB1->B1_COD))
		DbSelectArea("SZC")
		SZC->(DbSetOrder(1))
		If SZC->(DbSeek(xFilial("SZC")+cEmbarq))
			DbSelectArea("ZZM")
			ZZM->(DbSetOrder(1))
			If !ZZM->(DbSeek(xFilial("ZZM")+SZC->ZC_CODFORN + SZC->ZC_LOJAFOR))
				MsgAlert("Produto não encontrado no Aviso de Recebimento de Carga!")
				Return .F.
			Else
				If Alltrim(ZZM->ZZM_CODMAR) <> Alltrim(SB1->B1_XMARCA)
					MsgAlert("Marca do produto diferente do fornecedor do romaneio!")
					Return .F.
				EndIf
			EndIf
		Else
			MsgAlert("Embarque não encontrado!")
			Return .F.
		EndIf
	EndIf
	dbSelectArea("SZ8")
	dbSetOrder(1)
	If !SZ8->(MsSeek(xFilial("SZ8") + SB1->B1_COD + IIF(!Empty(DCY->DCY_LOCAL), DCY->DCY_LOCAL,"")))
		MsgInfo("Produto sem endereço")
	Else
		_cEnder := SZ8->Z8_ENDER
	Endif
	dbSelectArea("SB5")
	dbSetOrder(1)
	dbSeek(xFilial()+SB1->B1_COD)
	If Empty(SB5->B5_XCODZON)
		MsgInfo("SETOR NÃO INFORMADO NO CADASTRO DE COMPLEMENTO DO PRODUTO (SB5)")
	Else
		dbSelectArea(cAliasTmp)
		If !Eof() .and. !Bof() .and. !Empty((cAliasTmp)->TMP_PROD)
			dbSelectArea(cAliasTmp)
			dbSetOrder(3)
			DbGoBottom()
			If !Empty(_cEnder) .and. (cAliasTmp)->TMP_CODZON <> SB5->B5_XCODZON
				MsgInfo("NOVO SETOR:  --> " + SB5->B5_XCODZON)
			Endif
		Endif
	Endif
	DbSelectArea("DC4")
	DC4->(DbSetOrder(1))
	DC4->(MsSeek(xFilial("DC4") + SB5->B5_XCODZON))
	//Verifica se a primeira linha está vazia
	dbSelectArea(cAliasTmp)
	dbSetOrder(2)
	If dbSeek(SB1->B1_COD)
		_nQtTot :=  (cAliasTmp)->TMP_QTCONF + nQuant
		RecLock(cAliasTmp,.F.)
		Replace TMP_QTCONF with _nQtTot
		MsUnLock()
	Else
		dbSelectArea(cAliasTmp)
		dbSetOrder(3)
		DbGoBottom()
		_cItem := Soma1((cAliasTmp)->TMP_ITEM)
		If (cAliasTmp)->(Eof())
			RecLock(cAliasTmp,.T.)
		ElseIf _cItem == "01"
			RecLock(cAliasTmp,.F.)
		Else
			RecLock(cAliasTmp,.F.)
			Replace TMP_ORDER with "ZZ"
			MsUnLock()
			RecLock(cAliasTmp,.T.)
		Endif
		Replace TMP_ITEM 	with _cItem,;
		TMP_EMBARQ	with cEmbarq,;
		TMP_OPER	with __cUserID,;
		TMP_PROD	with SB1->B1_COD,;
		TMP_DESC	with SB1->B1_DESC,;
		TMP_LOTE	with IIF(Rastro(SB1->B1_COD),NextLote(SB1->B1_COD),Space(TAMSX3("ZCZ_LOTE")[1])),;
		TMP_SUBLOT	with Space(TAMSX3("ZCZ_SUBLOT")[1]),;
		TMP_QTCONF	with nQuant,;
		TMP_UM		with SB1->B1_UM,;
		TMP_LOCALI	with IIF(!Empty(SZ8->Z8_ENDER), SZ8->Z8_ENDER, "----  SEM LOCAL  ----"),;
		TMP_CODZON	with SB5->B5_XCODZON,;
		TMP_DESZON	with DC4->DC4_DESZON,;
		TMP_PRDORI	with SB1->B1_COD,;
		TMP_LOCAL	with DCY->DCY_LOCAL,;
		TMP_PALETE	with cPalete
		MsUnLock()
	Endif

	oGet2:Buffer := Space(TamSx3("B1_CODBAR")[1])
	oGet3:Buffer := Space(TamSx3("B1_COD")[1])
	oGet4:Buffer := Space(TamSx3("B1_XREFER")[1])

	dbSelectArea(cAliasTmp)
	dbSetOrder(1)
	dbGotop()

	oBrwTRB:Refresh(.T.)

	nQuant := 1
	oGet1:SetFocus()
	oGet1:Refresh()
Endif
//Retorna sempre verdadeiro pra poder conseguir sair do campo
lRet := .T.
Return lRet

//------------------------------------------------------------------------------------------------------------------
Static Function fnMarca2()

Local xA

For xA := 1 to Len(aArPrd)
	IF aArPrd[xA][1] .and. oLbx2:nAt <> xA
		MsgInfo("Já existe registro selecionado!")
		Return
	EndIf
Next

aArPrd[oLbx2:nAt,1] := !aArPrd[oLbx2:nAt,1]

Return

/*--------------------------------------------------------------------------------
---GravCofOpe
---Grava conferencia
---cEmbarque, character, (Embarque do conferencia de recebimento)
---cCodOpe, character, (Operador da  conferencia de recebimento)
---cPrdOri, character, (Produto origem da  conferencia de recebimento)
---cProduto, character, (Produto da conferencia de recebimento)
---cLoteCtl, character, (Lote do produto da conferencia de recebimento)
---cNumLote, character, (Sub-lote do lote do produto da conferencia de recebimento)
---nQtConf, numérico, (Quantidade conferida)
---lEstorno, Lógico, (Indica se é um estorno)
---cPalete, character, (Numero do palete a ser conferido)
----------------------------------------------------------------------------------*/

User Function GravCofOpe(_cItem, cEmbarque,cCodOpe,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtdConf,lEstorno,cPalete,cLocal, _cCodZon, _cLocaliz)

Local _aArea	:= GetArea()
Local nQuant    := 0
Local nI        := 0
Local oProdComp := Nil
Local lCompEnd  := .F.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local cWmsLcEx	:= SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
Local lExcesso	:= .F.
Local _nQtdAlt := 0
// Verifica situação do embarque
/*
DCW_SITEMB:

1 – Não iniciado;
2 – Volume em Andamento;
3 – Volume Conferido;
4 – Volume Conferido com Divergência;
5 – Produto em Andamento;
6 – Produto Conferido;
7 – Produto Conferido com Divergência.

*/

DCY->( dbSetOrder(1) )
IF !DCY->( dbSeek(xFilial('DCY')+cEmbarque+cPrdOri+cProduto) )		// Produto contado, porém não veio na NF mas mesmo assim inclui
	RecLock("DCY",.T.)
	Replace DCY_FILIAL with xFilial("DCY")
	Replace DCY_EMBARQ with cEmbarque
	Replace DCY_PROD   with cPrdOri
	Replace DCY_LOTE   with cLoteCtl
	Replace DCY_SUBLOT with cNumLote
	Replace DCY_QTORIG with 0
	Replace DCY_LOCAL  with cLocal
	Replace DCY_PRDORI with cPrdOri
	Replace DCY_QTCONF with 0
	DCY->(MsUnLock())
Endif

DCW->( dbSetOrder(1) )
DCW->( dbSeek(xFilial('DCW')+cEmbarque) )
If DCW->DCW_SITEMB <> '5'
	RecLock("DCW",.F.)
	DCW->DCW_SITEMB := '5'
	DCW->(MsUnlock())
Endif
dbSelectArea("SZC")
dbSetOrder(1)
If dbSeek(xFilial()+cEmbarque) .and. SZC->ZC_STATUS <> "2"
	RecLock("SZC",.F.)
	Replace ZC_STATUS with "2"
	MsUnLock()
Endif
dbSelectArea("ZCZ")
RecLock('ZCZ',.T.)
ZCZ->ZCZ_FILIAL := xFilial('ZCZ')
ZCZ->ZCZ_ITEM   := _cItem
ZCZ->ZCZ_DATA   := dDataBase
ZCZ->ZCZ_HORA	:= Time()
ZCZ->ZCZ_EMBARQ := cEmbarque
ZCZ->ZCZ_OPER   := cCodOpe
ZCZ->ZCZ_PRDORI := Iif(lWmsNew,cPrdOri,cProduto)
ZCZ->ZCZ_PROD   := cProduto
ZCZ->ZCZ_LOCAL  := cLocal
ZCZ->ZCZ_LOTE   := cLoteCtl
ZCZ->ZCZ_SUBLOT := cNumLote
ZCZ->ZCZ_QTCONF := nQtdConf
ZCZ->ZCZ_XPALET := cPalete
ZCZ->ZCZ_CODZON := _cCodZon
ZCZ->ZCZ_ENDER  := _cLocaliz
ZCZ->(MsUnLock())
_nQtdAlt := nQtdConf
If _nQtdAlt <> 0
	u_GrConfWMS(_cItem, cEmbarque,cCodOpe,cPrdOri,cProduto,cLoteCtl,cNumLote,_nQtdAlt,cPalete,cLocal)
Endif
RestArea(_aArea)
Return


//----------------------------------------------------------------------------------------------------------------------------
//
User Function GrConfWMS(_cItem, cEmbarque,cCodOpe,cPrdOri,cProduto,cLoteCtl,cNumLote,nQtdConf,cPalete,cLocal)

Local _aArea := GetArea()
Local _nQtdOri 	:= 0
Local _nQtdCof 	:= 0
Local cWmsLcEx	:= SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
Local bCampoDCY := { |nCPO| Field(nCPO)}

dbSelectArea("DCY")
dbSetOrder(1)
dbSeek(xFilial()+cEmbarque+cPrdOri+cPrdOri+cLoteCtl+cNumLote)
While !Eof() .and. xFilial("DCY")+cEmbarque+cPrdOri+cPrdOri+cLoteCtl+cNumLote == DCY->(DCY_FILIAL+DCY_EMBARQ+DCY_PRDORI+DCY_PROD+DCY_LOTE+DCY_SUBLOT)
	_nQtdOri += DCY->DCY_QTORIG
	_nQtdCof += DCY->DCY_QTCONF
	dbSkip()
End
_nDif := _nQtdOri - (_nQtdCof + nQtdConf)
If _nDif >= 0
	dbSelectArea("DCY")
	dbSetOrder(1)
	If dbSeek(xFilial()+cEmbarque+cPrdOri+cPrdOri+cLoteCtl+cNumLote+cLocal)
		RecLock("DCY",.F.)
		Replace DCY_QTCONF with DCY_QTCONF + nQtdConf
		MsUnLock()
		dbSelectArea("DCZ")
		dbSetOrder(1)
		If dbSeek(xFilial()+cEmbarque+cCodOpe+cPrdOri+cPrdOri+cLoteCtl+cNumLote+cLocal)
			RecLock("DCZ",.F.)
			Replace DCZ_QTCONF with DCZ_QTCONF + nQtdConf
			MsUnLock()
		Else
			RecLock("DCZ",.T.)
			Replace DCZ_FILIAL with xFilial("DCZ"),;
			DCZ_EMBARQ with cEmbarque,;
			DCZ_OPER with cCodOpe,;
			DCZ_PROD with cProduto,;
			DCZ_LOTE with cLoteCtl,;
			DCZ_SUBLOT with cNumLote,;
			DCZ_QTCONF with nQtdConf,;
			DCZ_PRDORI with cProduto,;
			DCZ_LOCAL with cLocal
			MsUnLock()
		Endif
	Endif
Else
	dbSelectArea("DCY")
	dbSetOrder(1)
	If dbSeek(xFilial()+cEmbarque+cPrdOri+cPrdOri+cLoteCtl+cNumLote+cLocal)
		FOR I := 1 to FCount()
			M->&(EVAL(bCampoDCY,I)) := FieldGet(I)
		Next I
		If DCY->DCY_QTORIG == 0 .and. DCY->DCY_QTCONF == 0
			RecLock("DCY",.F.)
			dbDelete()
			MsUnLock()
		Else
			RecLock("DCY",.F.)
			Replace DCY_QTCONF with DCY_QTORIG
			MsUnLock()
		Endif
		If dbSeek(xFilial()+cEmbarque+cPrdOri+cPrdOri+cLoteCtl+cNumLote+cWmsLcEx)
			RecLock("DCY",.F.)
			Replace DCY_QTCONF with ABS(_nDif)
			MsUnLock()
		Else
			M->DCY_LOCAL := cWmsLcEx
			M->DCY_QTCONF := ABS(_nDif)
			M->DCY_QTORIG := 0
			_nOpca := AxIncluiAuto("DCY")
		Endif
		_aTotDCZ := {}
		_nTotDCZ := 0
		dbSelectArea("DCZ")
		dbSetOrder(3)
		If dbSeek(xFilial()+cEmbarque+cPrdOri+cLoteCtl+cNumLote)
			While !Eof() .and. xFilial("DCZ")+cEmbarque+cPrdOri+cLoteCtl+cNumLote == DCZ->(DCZ_FILIAL+DCZ_EMBARQ+DCZ_PROD+DCZ_LOTE+DCZ_SUBLOT)
				aadd(_aTotDCZ, {DCZ->DCZ_PROD, DCZ->DCZ_OPER, DCZ->DCZ_LOCAL, DCZ->DCZ_QTCONF})
				_nTotDCZ += DCZ->DCZ_QTCONF
				dbSkip()
			End
		Endif
		If _nTotDCZ >= _nQtdOri
			dbSelectArea("DCZ")
			dbSetOrder(1)
			If dbSeek(xFilial()+cEmbarque+cCodOpe+cPrdOri+cPrdOri+cLoteCtl+cNumLote+cWmsLcEx)
				RecLock("DCZ",.F.)
				Replace DCZ_QTCONF with nQtdConf
				MsUnLock()
			Else
				RecLock("DCZ",.T.)
				Replace DCZ_FILIAL with xFilial("DCZ"),;
				DCZ_EMBARQ with cEmbarque,;
				DCZ_OPER with cCodOpe,;
				DCZ_PROD with cProduto,;
				DCZ_LOTE with cLoteCtl,;
				DCZ_SUBLOT with cNumLote,;
				DCZ_QTCONF with nQtdConf,;
				DCZ_PRDORI with cProduto,;
				DCZ_LOCAL with cWmsLcEx
				MsUnLock()
			Endif
		Else
			_nDif := _nQtdOri - _nTotDCZ
			_nMaior := nQtdConf - _nDif
			dbSelectArea("DCZ")
			dbSetOrder(1)
			If dbSeek(xFilial()+cEmbarque+cCodOpe+cPrdOri+cPrdOri+cLoteCtl+cNumLote+cLocal)
				RecLock("DCZ",.F.)
				Replace DCZ_QTCONF with DCZ_QTCONF + _nDif
				MsUnLock()
			Else
				RecLock("DCZ",.T.)
				Replace DCZ_FILIAL with xFilial("DCZ"),;
				DCZ_EMBARQ with cEmbarque,;
				DCZ_OPER with cCodOpe,;
				DCZ_PROD with cProduto,;
				DCZ_LOTE with cLoteCtl,;
				DCZ_SUBLOT with cNumLote,;
				DCZ_QTCONF with _nDif,;
				DCZ_PRDORI with cProduto,;
				DCZ_LOCAL with cLocal
				MsUnLock()
			Endif
			dbSelectArea("DCZ")
			dbSetOrder(1)
			If dbSeek(xFilial()+cEmbarque+cCodOpe+cPrdOri+cPrdOri+cLoteCtl+cNumLote+cWmsLcEx)
				RecLock("DCZ",.F.)
				Replace DCZ_QTCONF with DCZ_QTCONF + _nMaior
				MsUnLock()
			Else
				RecLock("DCZ",.T.)
				Replace DCZ_FILIAL with xFilial("DCZ"),;
				DCZ_EMBARQ with cEmbarque,;
				DCZ_OPER with cCodOpe,;
				DCZ_PROD with cProduto,;
				DCZ_LOTE with cLoteCtl,;
				DCZ_SUBLOT with cNumLote,;
				DCZ_QTCONF with _nMaior,;
				DCZ_PRDORI with cProduto,;
				DCZ_LOCAL with cWmsLcEx
				MsUnLock()
			Endif
		Endif
	Endif
Endif
RestArea(_aArea)
Return
//----------------------------------------------------------
User Function AN_ReCo
Local aAreaDCW  := DCW->(GetArea())
Local aAreaDCY  := DCY->(GetArea())
Local aAreaDCZ  := DCZ->(GetArea())
Local aAreaDCX  := DCX->(GetArea())
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""

If DCW->DCW_SITEMB < "6"
	WmsMessage("Reabertura permitida somente para recebimento conferido!",WMSA32008,1)
	lRet := .F.
EndIf
If lRet .And. DCW->DCW_TPCONF == '1'
	cQuery := "SELECT SD1.D1_TIPO_NF"
	cQuery +=  " FROM "+RetSqlName('D0K')+" D0K, "+RetSqlName('SD1')+" SD1"
	cQuery += " WHERE D0K.D0K_FILIAL  = '"+xFilial('D0K')+"'"
	cQuery +=   " AND D0K.D0K_EMBARQ  = '"+DCW->DCW_EMBARQ+"'"
	cQuery +=   " AND D0K.D_E_L_E_T_  = ' '"
	cQuery +=   " AND SD1.D1_FILIAL   = '"+xFilial('SD1')+"'"
	cQuery +=   " AND SD1.D1_DOC      = D0K.D0K_DOC"
	cQuery +=   " AND SD1.D1_SERIE    = D0K.D0K_SERIE"
	cQuery +=   " AND SD1.D1_FORNECE  = D0K.D0K_FORNEC"
	cQuery +=   " AND SD1.D1_LOJA     = D0K.D0K_LOJA"
	cQuery +=   " AND SD1.D1_COD      = D0K.D0K_PROD"
	cQuery +=   " AND SD1.D1_ITEM     = D0K.D0K_ITEM"
	cQuery +=   " AND SD1.D1_TES      <> ' '"
	cQuery +=   " AND SD1.D1_QUANT    > 0"
	cQuery +=   " AND SD1.D1_OP       = ' '"
	cQuery +=   " AND SD1.D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	If !(cAliasQry)->(EoF())
		WmsMessage("Conferência realizada como Prenota, não permitida a reabertura com o documento classificado.",WMSA32083,1) //
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
EndIf
If lRet .And. DCW->DCW_TPCONF == '2'
	cQuery := " SELECT DCF.DCF_ID"
	cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
	cQuery +=  " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=    " AND DCF.DCF_CODREC = '"+DCW->DCW_EMBARQ+"'"
	cQuery +=    " AND DCF.DCF_STSERV NOT IN ('0','1')"
	cQuery +=    " AND DCF.DCF_ORIGEM = 'D0R'"
	cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	If !(cAliasQry)->(EoF())
		WmsMessage("Conferência possui ordens de serviço executadas, não permitida a reabertura.",WMSA32098,1)
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
EndIf

If lRet .And. !A320LibArm(4,DCW->DCW_EMBARQ)
	WmsMessage("Reabertura não permitida, recebimento possui documento já armazenado!",WMSA32007,1)
	lRet := .F.
EndIf

If lRet
	If WmsQuestion("Confirma a reabertura do processo de conferência?") //
		Processa({|| lRet := Wm320RbCof(DCW->DCW_EMBARQ,DCW->DCW_TPCONF)}, "Reabrindo Conferência" , "Aguarde" + "...", .T.) //  //
		If lRet
			dbSelectArea("DCW")
			RecLock("DCW",.F.)
			Replace DCW_XSTATU with " "
			MsUnLock()
		Endif
	EndIf
EndIf
RestArea(aAreaDCX)
RestArea(aAreaDCZ)
RestArea(aAreaDCY)
RestArea(aAreaDCW)
Return lRet
/*--------------------------------------------------------------------------------
---FinCofRec
---Verifica/Finaliza conferencia de embarque
---Alexsander.Correa - 01/04/2015
---cEmbarque, character, (Embarque do conferencia de recebimento)
----------------------------------------------------------------------------------*/
User Function FinCofRAN(cEmbarque)
Local aAreaDCW := DCW->( GetArea() )
Local aAreaDCY := DCY->( GetArea() )
Local lRet     := .T.
Local aBoxDCW  := RetSx3Box(Posicione('SX3',2,'DCW_SITEMB','X3CBox()'),,,1)
Local cQuery
Local lDiverge := .F.

cQuery := "SELECT ZZL_PALETE, ZZL_OPER FROM " + RetSqlName("ZZL")
cQuery += " WHERE ZZL_FILIAL = '" + xFilial("ZZL") + "'"
cQuery += " AND ZZL_EMBARQ = '" + cEmbarque + "'"
cQuery += " AND ZZL_DTFECH = '        '"
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QZCZ",.F.,.T.)
dbSelectArea("QZCZ")
If !Eof()
	Help( NIL, NIL, "PALNENC", NIL, "Existem Paletes NÃO Encerrados", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Encerrar todos os Paletes."})
	QZCZ->(dbCloseArea())
	lRet := .f.
Else
	QZCZ->(dbCloseArea())
	DCW->( dbSetOrder(1) )
	If DCW->( dbSeek(xFilial('DCW')+cEmbarque) )

		If DCW->DCW_SITEMB <> "5"
			WmsMessage("Finalização permitida somente para embarque em andamento!",WMSA32009,1) //
			Return .F.
		EndIf

		If !WmsQuestion("Confirma a finalização do processo de conferência?") //
			Return .F.
		EndIf

		// Verifica se algum item foi conferido
		DCY->( dbSetOrder(1) )
		// DCY_FILIAL+DCY_EMBARQ+DCY_PROD+DCY_LOTE+DCY_SUBLOT
		DCY->( dbSeek(xFilial('DCY')+DCW->DCW_EMBARQ) )
		While !DCY->( Eof() ) .And.;
			DCY->DCY_FILIAL == xFilial('DCY') .And.;
			DCY->DCY_EMBARQ == DCW->DCW_EMBARQ .And.;
			lDiverge == .F.
			If QtdComp(DCY->DCY_QTORIG) <> QtdComp(DCY->DCY_QTCONF)
				lDiverge := .T.
			EndIf
			DCY->( dbSkip() )
		EndDo

		If lDiverge
			If !WmsQuestion("Foram encontradas divergencias na contagem. Confirma encerramento?")
				RestArea(aAreaDCY)
				RestArea(aAreaDCW)
				Return .F.
			EndIf
		EndIf
		If lRet
			Processa({|| lRet := A320FINCOF(DCW->DCW_EMBARQ,DCW->DCW_TPCONF,lDiverge)}, "Finalizando Conferência", "Aguarde" + "...", .T.)
		EndIf
		If lRet
			dbSelectArea("DCW")
			RecLock("DCW",.F.)
			Replace DCW_XSTATU with "1"
			MsUnLock()
			dbSelectArea("DCX")
			DCX->(dbSetOrder(1))
			dbSeek(xFilial("DCX")+DCW->DCW_EMBARQ)
			While !Eof() .and. xFilial("DCX")+ DCW->DCW_EMBARQ == DCX->(DCX_FILIAL + DCX_EMBARQ)
				dbSelectArea("SF1")
				dbSetOrder(1)
				If dbSeek(xFilial()+DCX->DCX_DOC+DCX->DCX_SERIE+DCX->DCX_FORNEC+DCX->DCX_LOJA)
					RecLock("SF1",.F.)
					Replace F1_STATCON with "1"
					MsUnLock()
				Endif
				dbSelectArea("DCX")
				dbSkip()
			End


			//		If MsgRun("Processando...","Aguarde",{|| Wms320FiCo()})
			//   01234567890123456789
			// 0 ____Conferência_____
			// 1 Recebimento: 000000
			// 2 --------------------
			// 3 Conferido
			// 4 --------------------
		Else
			//			WmsMessage("Não foi possível finalizar a conferência.",WMSA32012,2)
			lRet := .F.
		EndIf
	Else
		WmsMessage("Número recebimento informado não cadastrado.",WMSV09014,2)
		lRet := .F.
	EndIf
	RestArea(aAreaDCW)
Endif
__lAutoma := .F.
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³MA215Lock   ³ Autor ³ TOTVS S/A           ³ Data ³ 20.01.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Bloqueio de Empresas para o processamento da rotina        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Empresa                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA215                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrxPLock(cEmbarq)
Local lRet       := .T.
Local nTentativa := 0

nTentativa := 0
// Trava arquivo para somente este usuario utilizar rotina
While !LockByName("P"+cEmbarq+AllTrim(cEmpAnt+cFilAnt),.T.,.T.) .And. nTentativa <= 1000
	nTentativa++
	Sleep(100)
End
// Tenta travar 1000 vezes, e se nao conseguir coloca na lista de filiais com concorrencia
If nTentativa > 1000
	If !IsBlind()
		Aviso("Concorrência","Não foi possivel gerar o Id do Palete ",{"Ok"},2)
	EndIf
	lRet := .F.
EndIf
Return lRet
// Libera para armazenagem ou no Estorno quando não executado a armazenagem, volta para status para bloqueado
/*
nAcao:
1= Liberacao por item;
2= Liberacao da Conferencia de todo recebimento
*1 e 2= alteram o status da tarefa para 4=A Executar
3= Estorno da Conferencia, somente das tarefas que estao 4=A Executar, e volta Status para 2=Com Problema
4= Valida se pode reabrir conferencia
5= Estorno da Conferencia do Produto, somente das tarefas que estao 4=A Executar, e volta Status para 2=Com Problema
6= Estorno da Conferencia do Operador
7= Estorno da Conferencia Item do Operador
*/
Static Function A320LibArm(nAcao,cEmbarque,cProduto,cLoteCtl,cNumLote,cPrdOri,cOperador)
Local lRet    := .T.
Local lExec   := .F.

Default cProduto  := ''
Default cLoteCtl  := ''
Default cNumLote  := ''
Default cPrdOri   := ''
Default cOperador := ''
If __lWmsNew
	cQuery := "SELECT D12.R_E_C_N_O_ RECNOD12"
	cQuery += "  FROM "+RetSqlName('DCX')+" DCX,"+RetSqlName('DCF')+" DCF,"+RetSqlName('DCR')+" DCR,"+RetSqlName('D12')+" D12"
	If nAcao == 6 .Or. nAcao == 7
		cQuery += " ,"+RetSqlName('DCZ')+" DCZ"
	EndIf
	cQuery += " WHERE DCX.DCX_FILIAL = '"+xFilial('DCX')+"'"
	cQuery += "   AND DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery += "   AND DCR.DCR_FILIAL = '"+xFilial('DCR')+"'"
	cQuery += "   AND D12.D12_FILIAL = '"+xFilial('D12')+"'"
	cQuery += "   AND DCX.DCX_EMBARQ = '"+cEmbarque+"'"
	cQuery += "   AND DCX.DCX_DOC = DCF.DCF_DOCTO"
	cQuery += "   AND DCX.DCX_SERIE = DCF.DCF_SERIE"
	cQuery += "   AND DCX.DCX_FORNEC = DCF.DCF_CLIFOR"
	cQuery += "   AND DCX.DCX_LOJA = DCF.DCF_LOJA"
	cQuery += "   AND DCF.DCF_ID = DCR.DCR_IDORI"
	cQuery += "   AND DCR.DCR_IDDCF = D12.D12_IDDCF"
	cQuery += "   AND DCR.DCR_IDMOV = D12.D12_IDMOV"
	cQuery += "   AND DCR.DCR_IDOPER = D12.D12_IDOPER"
	cQuery += "   AND DCR.DCR_SEQUEN = D12.D12_SEQUEN"
	If nAcao == 1 .Or. nAcao == 5 .Or. nAcao == 7
		cQuery += " AND D12.D12_PRODUT = '"+cProduto+"'"
		cQuery += " AND D12.D12_LOTECT = '"+cLoteCtl+"'"
		cQuery += " AND D12.D12_NUMLOT = '"+cNumLote+"'"
		cQuery += " AND DCF.DCF_CODPRO = '"+cPrdOri+"'"
		If nAcao == 1
			cQuery += " AND D12.D12_STATUS = '2'"
		ElseIf nAcao == 5
			cQuery += " AND D12.D12_STATUS = '4'"
		EndIf
	ElseIf nAcao == 2
		cQuery += "   AND D12.D12_STATUS = '2'"
	ElseIf nAcao == 3
		cQuery += "   AND D12.D12_STATUS = '4'"
	EndIf
	If nAcao == 6 .Or. nAcao == 7
		cQuery += " AND DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
		cQuery += " AND DCZ.DCZ_EMBARQ = DCX.DCX_EMBARQ"
		cQuery += " AND DCZ.DCZ_OPER = '"+cOperador+"'"
		cQuery += " AND D12.D12_STATUS = '4'"
		cQuery += " AND DCZ.D_E_L_E_T_ = ''"
	EndIf
	cQuery += "   AND DCX.D_E_L_E_T_ = ' '"
	cQuery += "   AND DCF.D_E_L_E_T_ = ' '"
	cQuery += "   AND DCR.D_E_L_E_T_ = ' '"
	cQuery += "   AND D12.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		D12->(dbGoTo((cAliasQry)->RECNOD12))
		If nAcao == 1 .Or. nAcao == 2
			RecLock("D12",.F.)
			D12->D12_STATUS := "4"
			D12->(MsUnlock())
		ElseIf nAcao == 3 .Or. nAcao == 5 .Or. nAcao == 6 .Or. nAcao == 7
			RecLock("D12",.F.)
			D12->D12_STATUS := "2"
			D12->(MsUnlock())
		ElseIf nAcao == 4
			If D12->D12_STATUS == "1"
				lExec := .T.
			Else
				lExec := .F.
				Exit
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	If nAcao == 4 .And. lExec
		WmsMessage("Reabertura permitida somente para Armazenagem não executada!",WMSA32025,1) //
		lRet := .F.
	EndIf
EndIf
Return lRet