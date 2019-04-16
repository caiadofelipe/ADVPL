#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#include "FILEIO.CH"

#DEFINE ITEMSZ4 "Z4_CODTAB/Z4_GRUPO/Z4_SUBGRP/Z4_DESC01/Z4_DESC02/Z4_DESC03/Z4_DESC04/Z4_DESC05/Z4_DESC06/Z4_DESC07/Z4_DESC08/Z4_DESC09/Z4_DESC10/Z4_TPDESC/Z4_TOTDESC/Z4_NACIMP/"
#DEFINE ITEMSZ5 "Z5_CODTAB/Z5_CODREF/Z5_DESC01/Z5_DESC02/Z5_DESC03/Z5_DESC04/Z5_DESC05/Z5_DESC06/Z5_DESC07/Z5_DESC08/Z5_DESC09/Z5_DESC10/Z5_TPDESC/Z5_TOTDESC/"
#DEFINE ITEMSZ6 "Z6_CODTAB/Z6_DESC01/Z6_DESC02/Z6_DESC03/Z6_DESC04/Z6_DESC05/Z6_DESC06/Z6_DESC07/Z6_DESC08/Z6_DESC09/Z6_DESC10/Z6_TOTDESC/Z6_NACIMP/Z6_DESCRI/"

#DEFINE ENTER Chr(10)+Chr(13)

Static _lConfirmar    := .T.
Static __lBTNConfirma := .F.
STATIC _aColsForn := {}

/*{Protheus.doc}AN_LISTPRC
@author Ricardo Rotta
@since 27/08/2018
@version P12
Lista de Preço
*/
//-------------------------------------------------------------------

User Function AN_LISTPRC(xRotAuto,nOpcAuto)

	Local oBrowse := NIL
	Private aLstSobP := {}
	If xRotAuto == Nil
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("SZ2")
		oBrowse:SetDescription(OemToAnsi("Politica Comercial"))
		oBrowse:AddLegend( "Z2_STATUS == '1'" , "GREEN" , "Tabela Não Vigente"	)
		oBrowse:AddLegend( "Z2_STATUS == '2'" , "RED"	, "Tabela Vigente"	)
		oBrowse:AddLegend( "Z2_STATUS == '3'" , "YELLOW", "Politica Comercial Não Aplicada"	)
		oBrowse:Activate()
	Else
		aRotina := MenuDef()
		FWMVCRotAuto(ModelDef(),"SZ2",nOpcAuto,{{"Z2MASTER",xRotAuto},{"Z3DETAIL",aSZ3}})
	Endif
Return

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Alterar Planilha'			Action "StaticCall(AN_LISTPRC,AN_VIEWTAB)" 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Importar' 				Action "StaticCall(AN_LISTPRC,AN_IMPPRC)"  	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar' 					Action 'VIEWDEF.AN_LISTPRC' 				OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir' 					Action "StaticCall(AN_LISTPRC,AN_EXCPRV)"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Sobrepor'					ACTION "StaticCall(AN_LISTPRC,SOBREPOR)"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Copiar Politica Desconto'	Action "StaticCall(AN_LISTPRC,AN_COPPOL)"  	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Aplicar Política'			Action "U_AN_CALCPRV(1)" 					OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Efetivar Tabela'			Action "U_AN_CALCPRV(2)" 					OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Simulação Tabela Preço'	ACTION 'StaticCall(AN_LISTPRC,SIMUPRV)'		OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Relatorio Variação Preço'	ACTION 'u_RSIMTAB'							OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Banco Conhecimento'		ACTION "StaticCall(AN_LISTPRC,LISTPRCDOC)"	OPERATION 2 ACCESS 0

Return aRotina
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStPai   := FWFormStruct( 1, 'SZ2')
	Local oStSZ4   := FWFormStruct( 1, 'SZ4', { |cCampo|  AllTrim( cCampo ) + '/' $ ITEMSZ4 } ,/*lViewUsado*/ )
	Local oStSZ5   := FWFormStruct( 1, 'SZ5', { |cCampo|  AllTrim( cCampo ) + '/' $ ITEMSZ5 } ,/*lViewUsado*/ )
	Local oStSZ6   := FWFormStruct( 1, 'SZ6', { |cCampo|  AllTrim( cCampo ) + '/' $ ITEMSZ6 } ,/*lViewUsado*/ )
	Local oModel
	Local aPAIRel  := {}
	Local cPerg   := "ANPRCFRN1"

	oModel := MPFormModel():New('AN_LISTM' , , { |oModel| PRCFORPOS( oModel )}, { |oModel| AN_LTMGRV( oModel ) } )

	nOperation := oModel:GetOperation()

	oModel:AddFields('Z2MASTER',/*cOwner*/,oStPai)

	oModel:AddGrid('Z4DETAIL','Z2MASTER',oStSZ4,/*bLinePre*/ , { |oMdlG| PRCFRNSZ4( oMdlG ) },/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	oModel:SetRelation( "Z4DETAIL", { { "Z4_FILIAL", "xFilial('SZ4')" }, { "Z4_CODTAB", "Z2_CODTAB" } }, SZ4->( IndexKey( 1 ) ) )
	oModel:SetPrimaryKey({})
	oModel:GetModel( 'Z4DETAIL' ):SetOptional( .T. )
	oModel:GetModel('Z4DETAIL'):SetUniqueLine( {"Z4_GRUPO","Z4_SUBGRP","Z4_NACIMP"} )

	oModel:AddGrid('Z5DETAIL','Z2MASTER',oStSZ5,/*bLinePre*/ , { |oMdlG| PRCFRNSZ5( oMdlG ) },/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	oModel:SetRelation( "Z5DETAIL", { { "Z5_FILIAL", "xFilial('SZ5')" }, { "Z5_CODTAB", "Z2_CODTAB" } }, SZ5->( IndexKey( 1 ) ) )
	oModel:SetPrimaryKey({})
	oModel:GetModel( 'Z5DETAIL' ):SetOptional( .T. )
	oModel:GetModel('Z5DETAIL'):SetUniqueLine( {"Z5_CODREF"} )

	oModel:AddGrid('Z6DETAIL','Z2MASTER',oStSZ6,/*bLinePre*/ , { |oMdlG| PRCFRNSZ6( oMdlG ) },/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
	oModel:SetRelation( "Z6DETAIL", { { "Z6_FILIAL", "xFilial('SZ6')" }, { "Z6_CODTAB", "Z2_CODTAB" } }, SZ6->( IndexKey( 1 ) ) )
	oModel:SetPrimaryKey({})
	oModel:GetModel( 'Z6DETAIL' ):SetOptional( .T. )
	oModel:GetModel("Z6DETAIL"):SetMaxLine( 2 )
	oModel:GetModel('Z6DETAIL'):SetUniqueLine( {"Z6_NACIMP"} )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( "Lista de Preços" )
	oStPai:SetProperty( 'Z2_CODTAB'	, MODEL_FIELD_WHEN	, { || .F. } )
	oStPai:SetProperty( 'Z2_MARCA' 	, MODEL_FIELD_WHEN	, { || .F. } )
	oStPai:SetProperty( 'Z2_CODFORN', MODEL_FIELD_WHEN	, { || .F. } )
	oStPai:SetProperty( 'Z2_LOJA' 	, MODEL_FIELD_WHEN	, { || .F. } )

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView     := Nil
	Local oModel    := FWLoadModel('AN_LISTPRC')
	Local oStPai 	:= FWFormStruct( 2, 'SZ2')
	Local oStSZ4    := FWFormStruct( 2, 'SZ4', { |cCampo|  AllTrim( cCampo ) + '/' $ ITEMSZ4 } ,/*lViewUsado*/ )
	Local oStSZ5    := FWFormStruct( 2, 'SZ5', { |cCampo|  AllTrim( cCampo ) + '/' $ ITEMSZ5 } ,/*lViewUsado*/ )
	Local oStSZ6    := FWFormStruct( 2, 'SZ6', { |cCampo|  AllTrim( cCampo ) + '/' $ ITEMSZ6 } ,/*lViewUsado*/ )
	Local nOperation := oModel:GetOperation()
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oStSZ4:RemoveField('Z4_CODTAB')
	oStSZ5:RemoveField('Z5_CODTAB')
	oStSZ6:RemoveField('Z6_CODTAB')

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_SZ2',oStPai,'Z2MASTER')
	oView:AddGrid('VIEW_SZ4',oStSZ4,'Z4DETAIL')
	oView:AddGrid('VIEW_SZ5',oStSZ5,'Z5DETAIL')
	oView:AddGrid('VIEW_SZ6',oStSZ6,'Z6DETAIL')

	/*
	oView:CreateFolder( 'PASTAS')
	// Cria pastas nas folders
	oView:AddSheet( 'PASTAS', 'ABA1', 'Lista de Preços' )
	oView:AddSheet( 'PASTAS', 'ABA2', 'Politica Comercial', {|| AtuDscG()} )
	*/

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox( 'CABEC', 20)
	oView:CreateHorizontalBox( 'GRID3', 25)
	oView:CreateHorizontalBox( 'GRID1', 30)
	oView:CreateHorizontalBox( 'GRID2', 25)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_SZ2','CABEC')
	oView:SetOwnerView('VIEW_SZ6','GRID3')
	oView:SetOwnerView('VIEW_SZ4','GRID1')
	oView:SetOwnerView('VIEW_SZ5','GRID2')

	//Habilitando título
	oView:EnableTitleView('VIEW_SZ2','Tabela de Preço')
	oView:EnableTitleView('VIEW_SZ4','Desconto por Grupo/SubGrupo')
	oView:EnableTitleView('VIEW_SZ5','Desconto por Produto')
	oView:EnableTitleView('VIEW_SZ6','Desconto Geral')

Return oView
//-------------------------------------------------------------------
Static Function AN_LTMGRV( oModel )

	Local _aArea	 := GetArea()
	Local nOperation := oModel:GetOperation()
	Local cFilTab    := SZ2->Z2_FILIAL
	Local _cCodTab	 := SZ2->Z2_CODTAB
	Local aTab       := {}
	Private lEnd 	 := .F.
	FWFormCommit( oModel )

	If nOperation == 5  // Exclusão
		_cUpd := "DELETE " + RetSqlName("SZ3")
		_cUpd += " WHERE Z3_FILIAL = '" + xFilial("SZ3") + "'"
		_cUpd += " AND Z3_CODTAB = '" + _cCodTab + "'"
		nErrQry := TCSqlExec( _cUpd )
	Endif

	If nOperation == 4 //Alteração
		AADD(aTab,{cFilTab,_cCodTab})
		Processa( {|lEnd| APLICPOL(aTab, @lEnd)}, "Aguarde...","Aplicando Politica Comercial", .T. )
	Endif

	RestArea(_aArea)
Return .T.

//-------------------------------------------------------------------

Static Function AN_IMPPRC

	Local _lRet
	Local nLargura := 400
	Local nAltura  := 350
	Local _cFilSel := "Todas Filiais"
	Local _aSelFil := {}
	Local _cTabOri := CriaVar("Z2_CODTAB",.F.)
	Local _cDscOri := CriaVar("Z2_DESCTAB",.F.)
	aadd(_aSelFil, "Filial Corrente")
	aadd(_aSelFil, "Seleciona Filiais")

	Private _cNReduz := CriaVar("A2_NREDUZ",.F.)
	Private _cCodMarc := CriaVar("ZZ7_MARCA",.F.)
	Private _cDescTab := CriaVar("Z2_DESCTAB",.F.)
	Private cFile  := Space(99999)
	Private oDlgWOF
	DEFINE DIALOG oDlgWOF TITLE "Seleção Importação" FROM 0, 0 TO 22, 90 SIZE nLargura, nAltura PIXEL //

	//Painel Origem
	oPanelOrigem   := TPanel():New( 005, 005, ,oDlgWOF, , , , , , nLargura-10, nAltura-19, .F.,.T. )
	@ 00,000 SAY oSay  VAR "Informe os Dados da Tabela para importacao" OF oPanelOrigem FONT (TFont():New('Arial',0,-13,.T.,.T.)) PIXEL //"Origem"

	@ 18,005 SAY oDescTab VAR "Descrição Tabela:" OF oPanelOrigem PIXEL
	@ 16,055 MSGET _cDescTab SIZE 120,010 OF oPanelOrigem WHEN .T. PIXEL

	@ 37,005 SAY oCodM VAR "Marca" OF oPanelOrigem PIXEL
	@ 35,030 MSGET oCODMAR  VAR _cCodMarc SIZE 030, 010 OF oPanelOrigem PIXEL VALID(BuscForn())
	oCODMAR:cF3 := "ZZ7"
	@ 35,065 MSGET oNReduz  VAR _cNReduz SIZE 080, 010 OF oPanelOrigem PIXEL WHEN .F.

	@ 57,005 SAY oCopPo VAR "Copiar Politica Comercial da Tabela:" OF oPanelOrigem PIXEL
	@ 55,100 MSGET oTabOri  VAR _cTabOri SIZE 030, 010 OF oPanelOrigem PIXEL Valid(VldCopTab(_cTabOri, @_cDscOri, "zz"))
	@ 67,005 MSGET oDscOri  VAR _cDscOri SIZE 080, 010 OF oPanelOrigem PIXEL WHEN .F.

	@ 87,005 SAY oAcao VAR "Arquivo" OF oPanelOrigem PIXEL //"Arquivo:"
	@ 97,005 MSGET cFile SIZE 140,010 OF oPanelOrigem WHEN .T. PIXEL
	@ 97,150 BUTTON oBtnAvanca PROMPT "Abrir" SIZE 15,12 ACTION (SelectFile()) OF oPanelOrigem PIXEL //"Abrir"

	@ 120,005 SAY oEmp VAR "Carrega Filiais " OF oPanelOrigem PIXEL //"Arquivo:"
	@ 118,050 COMBOBOX oSelFil VAR _cFilSel ITEMS _aSelFil SIZE 75,15 OF oPanelOrigem PIXEL

	//Painel com botões
	oPanelBtn := TPanel():New( (nAltura/2)-14, 0, ,oDlgWOF, , , , , , (nLargura/2), 14, .F.,.T. )
	@ 000,((nLargura/2)-122) BUTTON oBtnAvanca PROMPT "Confirmar"  SIZE 60,12 ACTION (VldSele(_cTabOri, _cFilSel)) OF oPanelBtn PIXEL
	@ 000,((nLargura/2)-60)  BUTTON oBtnAvanca PROMPT "Cancelar"   SIZE 60,12 ACTION (oDlgWOF:End()) OF oPanelBtn PIXEL //"Cancelar"

	ACTIVATE MSDIALOG oDlgWOF CENTER
Return

//-------------------------------------------------------------------
//Valida Fornecedor
//-------------------------------------------------------------------
Static Function BuscForn()
	Local _lRet := .t.
	Local _aCodForn := u_MPosFor(_cCodMarc)
	If Len(_aCodForn) > 0
		If !Empty(_cCodMarc)
			dbSelectArea("ZZ7")
			dbSetOrder(1)
			If dbSeek(xFilial()+_cCodMarc)
				_cNReduz := ZZ7->ZZ7_DESCRI
			Else
				Help(" ",1,"HELP","EXCADFORN","Codigo da Marca não encontrado",3,1)
				_lRet := .f.
			Endif
			oNReduz:Refresh()
		Endif
	Else
		Help(" ",1,"HELP","NCADFORN","Fornecedor não cadastrado",3,1)
		_lRet := .f.
	Endif
Return(_lRet)
//-------------------------------------------------------------------
//Select File - Seleciona Arquivo
//-------------------------------------------------------------------
Static Function SelectFile()

	cFile := cGetFile("Arquivo de Texto" + "|*.csv|" + "Todos Arquivos" + "|*.*","Selecione o arquivo para importação",0,GetMV("MV_XPATHPF",,"C:\"),.T.,nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE ) ,.F.)//"Arquivo de Texto","Todos Arquivos","Selecione o arquivo para importação"

Return Nil
//-------------------------------------------------------------------
//Valida Campos Digitados
//-------------------------------------------------------------------
Static Function VldSele(_cTabOri, _cFilSel)

	Local _lRet := .t.
	Local _aArea := GetArea()
	Local _cFileTab := Alltrim(cFile)
	Local nTentativa := 0
	Local _lExclusiva := .T.

	While !LockByName("IMPTABFIL",.T.,.T.)
		nTentativa ++
		If nTentativa > 99000
			_lExclusiva := .F.
			Exit
		EndIf
	End
	If _lExclusiva
		If !Empty(_cCodMarc)
			dbSelectArea("ZZ7")
			dbSetOrder(1)
			If !dbSeek(xFilial()+_cCodMarc)
				Help(" ",1,"HELP","EXISTFORN","Codigo do Fornecedor não encontrado",3,1)
				_lRet := .f.
			Endif
		Else
			Help(" ",1,"HELP","VAZIOFORN","Favor preencher o Codigo e a Loja do Fornecedor",3,1)
			_lRet := .f.
		Endif
		If _lRet
			If Empty(_cDescTab)
				Help(" ",1,"HELP","VAZIODESC","Favor preencher a descrição da tabela",3,1)
				_lRet := .f.
			Endif
		Endif
		If _lRet
			If !Empty(_cFileTab)
				If FOpen(Alltrim(_cFileTab)) > 0
					_lRet := Processa( {|lEnd| ValidFile(_cTabOri, _cFilSel, _cFileTab)}, "Aguarde...","Importando tabela de preço", .T. )
					oDlgWOF:End()
				Else
					Help(" ",1,"HELP","NARQUI","Arquivo informado não encontrado",3,1)
				Endif
			Else
				Help(" ",1,"HELP","ARQUINF","Favor informar o caminho do arquivo para importar",3,1)
			Endif
		Endif
		UnLockByName("IMPTABFIL",.T.,.T.)
	Else
		Help(" ",1,"HELP","EXCLUSIV","Processo de importação de Tabela está sendo utilizada, aguarde finalizar",3,1)
	Endif
	RestArea(_aArea)
Return(_lRet)
//-------------------------------------------------------------------
//Valid File - Valida o arquivo
//-------------------------------------------------------------------
Static Function ValidFile(_cTabOri, _cFilSel, _cFileTab)

	Local nI, nJ
	Local nHandle
	Local aModels
	Local nTipo        := 0
	Local nTipoAnt     := 0
	Local aDados       := {}
	Local cLinha       := ""
	Local lErro	       := .F.
	Local lErroLinha   := .F.
	Local lContinua    := .T.
	Local lAchou       := .F.
	Local lHlpDark
	Local cLabel       := ''
	Local lErroArq     := .F.
	Local nQuant       := 0
	Local _aCodForn		:= {}
	Local _aRetCus		:= {}
	Local aSelFil		:= {}
	Local cFilOri		:= cFilAnt
	Local _aCabec		:= {}
	Local _nPosCod := 0
	Local _nPosPRC := 0
	Local _nPosIPI := 0
	Local _nPosICM := 0
	Local _nPosGRP := 0
	Local _nPosSGP := 0
	Local _nPosUNP := 0
	Local aArqTmp     := {}
	Local aArqTab     := {}
	Local aEstruSZ3	  := SZ3->( dbStruct() )
	Local aIndex	  := {}
	Local oTabTmp
	Local cAliasTmp := GetNextAlias()
	Local lCriaTMP  := .t.
	Local _nQtDados := 1
	Local _aDadosIn	:= {}
	Local _lMultMarc := .F.
	Local _aMultMarc := {}
	Default _cTabOri    := CriaVar("Z2_CODTAB")
	lHlpDark := HelpInDark(.T.)

	//aadd(_aSelFil, "Filial Corrente")
	//aadd(_aSelFil, "Seleciona Filiais")

	If Substr(_cFilSel,1,1) == "S"
		aSelFil := PRCGetFil()
	Else
		aadd(aSelFil, cFilAnt)
	Endif

	If Len( aSelFil ) <= 0
		Return
	EndIf

	If FOpen(Alltrim(_cFileTab)) > 0
		//Lê o arquivo completo
		FT_FUSE(_cFileTab)
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo dados do arquivo....")
			cLinha := FT_FREADLN()
			If Len(_aCabec) == 0
				_aCabec := aClone(Separa(cLinha,";",.T.))
				_nMaior := 0
				For nX:= 1 to Len(_aCabec)
					If "COD" $ UPPER(Alltrim(_aCabec[nX]))
						_nPosCod := nx
						_nMaior  := nx
					Endif
					If "PRC" $ UPPER(Alltrim(_aCabec[nX]))
						_nPosPRC := nx
						_nMaior  := nx
					Endif
					If "IPI" $ UPPER(Alltrim(_aCabec[nX]))
						_nPosIPI := nx
						_nMaior  := nx
					Endif
					If "ICM" $ UPPER(Alltrim(_aCabec[nX]))
						_nPosICM := nx
						_nMaior  := nx
					Endif
					If "GRUPO" == UPPER(Alltrim((_aCabec[nX])))
						_nPosGRP := nx
						_nMaior  := nx
					Endif
					If "SUBGRUPO" == UPPER(Alltrim((_aCabec[nX])))
						_nPosSGP := nx
						_nMaior  := nx
					Endif
					If "UNP" == UPPER(Alltrim((_aCabec[nX])))
						_nPosUNP := nx
						_nMaior  := nx
					Endif
				Next

				If _nPosCod == 0 .or. _nPosPRC == 0
					Help(" ",1,"HELP","NFPROD","Verifique o arquivo pois não foram encontrados os campos referente ao Produto e ao Preço",3,1)
					lErro := .T.
					Return(lErro)
				Endif
			Else
				aAdd(aDados,Separa(cLinha,";",.T.))
				//validação das informações
				If _nPosCod > 0
					If Empty(aDados[Len(aDados),_nPosCod])
						FT_FSKIP()
						LOOP
					Endif
				Endif
				If _nPosPRC > 0
					If Empty(aDados[Len(aDados),_nPosPRC]) .OR. Len(Separa(aDados[Len(aDados),_nPosPRC],",")) > 2
						aDados[Len(aDados),_nPosPRC] := "0,01"
						MsgAlert("Verifique o arquivo pois não foram encontrados os Preços na posição"+cValToChar(Len(aDados)+1))
					Endif
				Endif
				If _nPosIPI > 0
					If Empty(aDados[Len(aDados),_nPosIPI]) .OR. Len(Separa(aDados[Len(aDados),_nPosIPI],",")) > 2
						aDados[Len(aDados),_nPosIPI] := "0,01"
						MsgAlert("Verifique o arquivo pois não foram encontrados os IPI na posição"+cValToChar(Len(aDados)))
					Endif
				Endif
				If _nPosICM > 0
					If Empty(aDados[Len(aDados),_nPosICM]) .OR. Len(Separa(aDados[Len(aDados),_nPosICM],",")) > 2
						aDados[Len(aDados),_nPosICM] := "0,01"
						MsgAlert("Verifique o arquivo pois não foram encontrados os ICMS na posição"+cValToChar(Len(aDados)))
					Endif
				Endif
				//Fim das validações
			Endif
			FT_FSKIP()
		EndDo
		FT_FUSE()
		If Len(aDados) > 0 .and. Len(_aCabec) > 0
			Aadd( aIndex, "Z3_FILIAL", "Z3_CODTAB" )
			CriaTabTmp(aEstruSZ3,aIndex,cAliasTmp,@oTabTmp)
			nH:=1
			cFilAnt := aSelFil[nH]
			ProcRegua(Len(aDados))
			_aRetCus := {}
			_cDados  := ""
			_nTotReg := 0
			dbSelectArea("ZZR")
			dbSetOrder(1)
			If dbSeek(xFilial()+_cCodMarc)		// Se encontrou é porque existem mais de 1 marca no arquivo
				_lMultMarc := .T.
				While !Eof() .and. xFilial()+_cCodMarc == ZZR->(ZZR_FILIAL+ZZR_GRPMAR)
					aadd(_aMultMarc, ZZR->ZZR_MARCA)
					dbSkip()
				End
			Endif
			For nJ:=1 to Len(aDados)
				IncProc("Importando Registros....")
				ProcessMessage() // Minimiza o efeito de 'congelamento' da aplicação
				If Len(aDados[nJ]) < _nMaior
					Loop
				Endif
				_cCodInt := " "
				_cDescri := " "
				_cRefFor := " "
				_cTpOP	 := "01"
				_cGrpTrib := " "
				_nPisCOF := 0
				_nICMRET := 0
				_nCusto  := 0
				_cTES	 := " "
				_cMonoFas := " "
				_nMargem  := 0
				_nDescVen := 0
				_nLetra   := 0
				_nFator   := 0
				_cLetra   := " "
				If Val(StrTran(aDados[nJ,_nPosPRC],",",".")) > 0
					dbSelectArea("SB1")
					dbOrderNickName("B1REFFOR")
					If _lMultMarc
						For nB:=1 to Len(_aMultMarc)
							If dbSeek(xFilial()+PADR(Alltrim(aDados[nJ,_nPosCod]), TAMSX3("B1_XREFFOR")[1])+Alltrim(_aMultMarc[nB]))
								Exit
							Endif
						Next
					Else
						dbSeek(xFilial()+PADR(Alltrim(aDados[nJ,_nPosCod]), TAMSX3("B1_XREFFOR")[1])+Alltrim(_cCodMarc))
					Endif

					If Found()
						_cCodInt := SB1->B1_COD
						_cDescPr := Alltrim(SB1->B1_DESC)
						_cDescri := PADR(RET_ACENT(_cDescPr), TAMSX3("Z3_DESCRI")[1])	// Retira caracter especiais
						_cRefFor := SB1->B1_XREFER
						_cTpOP	 := "01"
						_cGrpTrib := SB1->B1_GRTRIB
						_cMonoFas := IIF(SB1->B1_XMONO=="S","S","N")
						_cLinhaSB1  := SB1->B1_XLINHA
						_nMargem  := 0
						dbSelectArea("SBZ")
						dbSetOrder(1)
						If dbSeek(xFilial()+_cCodInt)
							_cLetra	  := Substr(SBZ->BZ_XLETRA,1,1)
						Else
							_cLetra   := " "
						Endif
						_aRetMark 	:= u_RetMarkup(_cMonoFas, _cCodMarc, _cLinhaSB1, cFilAnt)
						_nMarKup  	:= _aRetMark[1]
						_nLetra 	:= u_RetLetra(_cLetra)
						_nMargem 	:= (1 + (_nMarKup/100)) * _nLetra
						_nMargem 	:= Round((_nMargem - 1) * 100,2)
						If _nMargem < 0
							_nMargem := 0
						Endif
						//Converte valores para a primeira unidade de medida - Walter - 14/02/2019
						If _nPosUNP > 0
							If Alltrim(aDados[nJ,_nPosUNP]) == Alltrim(Posicione("SB1",1,xFilial("SB1")+_cCodInt,"B1_SEGUM"))
								nConv := ConvUM(_cCodInt,0,1,1)
								If nConv <> 0
									nValCX := Val(StrTran(aDados[nJ,_nPosPRC],",","."))
									aDados[nJ,_nPosPRC] := cValToChar(nValCX/nConv)
								Endif
							Endif
						Endif
						//Fim da conversão
					Endif
					_cCodRef := PADR(Alltrim(StrTran(aDados[nJ,_nPosCod], "'","")),TAMSX3("Z3_CODREF")[1])
					_cDados :=      " ('" + xFilial("SZ3") + "',"									// 1
					_cDados +=      " '" + _cCodInt + "'," 											// 2
					_cDados +=      " '" + _cDescri + "'," 											// 2
					_cDados +=      " '" + _cRefFor + "'," 											// 2
					_cDados +=      " '01'," 														// 3
					_cDados +=      " '" + _cGrpTrib + "'," 										// 4
					_cDados +=      Alltrim(Str(_nPisCOF)) + ","		 							// 5
					_cDados +=      " '" + _cTES + "'," 											// 6
					_cDados +=      Alltrim(Str(_nCusto)) + "," 									// 7
					_cDados +=      Alltrim(Str(_nICMRET)) + "," 									// 8
					_cDados +=      " ' '," 														// 9
					_cDados +=      " '" + _cMonoFas + "'," 										// 10
					_cDados +=      " '" + Substr(_cCodRef,1,TAMSX3("Z3_CODREF")[1]) + "',"			// 11
					_cDados +=      StrTran(aDados[nJ,_nPosPRC],",",".") + "," 				// 12
					_cDados +=      StrTran(aDados[nJ,_nPosPRC],",",".") + "," 				// 13
					_cDados +=      " '" + _cLetra + "'," 											// 14
					_cDados +=      Alltrim(Str(_nMargem)) + "," 							// 15
					_cDados +=      Alltrim(Str(_nDescVen)) + "," 							// 16
					_cDados +=      Alltrim(Str(_nFator)) + "," 							// 17
					If _nPosIPI > 0
						_cDados +=      StrTran(aDados[nJ,_nPosIPI],",",".") + "," 			// 18
					Else
						_cDados +=      "0," 													// 18
					Endif
					If _nPosICM > 0
						_cDados +=      StrTran(aDados[nJ,_nPosICM],",",".") + "," 			// 19
						_cDados +=      " '" + IIF(Val(aDados[nJ,_nPosICM]) == 4,"I","N") + "'," 	// 20
					Else
						_cDados +=      "0," 													// 19
						_cDados +=      " 'N'," 													// 20
					Endif
					If _nPosGRP > 0
						_cDados +=      " '" + aDados[nJ,_nPosGRP] + "'," 							// 21
					Else
						_cDados +=      " ' '," 													// 21
					Endif
					If _nPosSGP > 0
						_cDados +=      " '" + aDados[nJ,_nPosSGP] + "')" 							// 22
					Else
						_cDados +=      " ' ')" 													// 22
					Endif
					aadd(_aDadosIn, _cDados)
					If Len(_aDadosIn) >= 1024 .or. nJ == Len(aDados)
						If !CarregaTmp(cAliasTmp, oTabTmp:oStruct:aFields, oTabTmp, _aDadosIn, lCriaTMP)
							lErro  := .T.
							Exit
						Endif
						lCriaTMP := .F.
						_aDadosIn := {}
					Endif
				Endif
			Next
			If !lErro
				If !Empty(_cDados)
					lErro := !CarregaTmp(cAliasTmp, oTabTmp:oStruct:aFields, oTabTmp, _aDadosIn, lCriaTMP)
				Endif
				If !lErro
					IMPTabFil(aSelFil, _cTabOri, _cFileTab, oTabTmp)
					DelTabTmp(cAliasTmp,oTabTmp)
				Endif
			Endif
		Endif
	Endif
	cFilAnt := cFilOri
Return(lErro)

//---------------------------------------------------------------------------------------------------------------

Static Function GrvArqImp(_lGrvACB, cFile, cIdTab, _cTabID)

	Local _aArea := GetArea()
	Local _aAreaZ2 := SZ2->(GetArea())
	Local cArqDest  := ""
	Local cExt		:= ""
	Local nSaveSx8	:= GetSx8Len()
	Local _cChaveAC9:= PADR(xFilial("SZ2")+cIdTab, TAMSX3("AC9_CODENT")[1])
	Local _cCodObj
	Local _lContinua := .T.
	Local cAliasSZ2 := "QRYCHN"
	If _lGrvACB
		dbSelectArea("ACB")
		RegToMemory( "ACB", .F.,,,)
		cObjeto := cFile
		SplitPath( cObjeto,,, @cArqDest, @cExt )
		_cOBJETO := Left( Upper( cArqDest + cExt ), Len( ACB->ACB_OBJETO ) )
		M->ACB_OBJETO := _cOBJETO
		M->ACB_DESCRI := _cOBJETO
		dbSelectArea("ACB")
		dbSetOrder(3)
		If !dbSeek(xFilial()+_cOBJETO)  // Inclui o arquivo no Banco de Conhecimento
			If FT340CpyObj(cFile)
				dbSelectArea( "ACB" )
				dbSetOrder(1)
				_cCodObj := GetSxeNum("ACB","ACB_CODOBJ")
				If !dbSeek(xFilial()+_cCodObj)
					While !Eof()
						_cCodObj := GetSxeNum("ACB","ACB_CODOBJ")
						dbSeek(xFilial()+_cCodObj)
					End
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava os demais campos inclusive especificos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RecLock( "ACB", .T. )
				ACB->ACB_FILIAL  := xFilial( "ACB" )
				ACB->ACB_CODOBJ  := _cCodObj
				If FindFunction( "MsMultDir" ) .And. MsMultDir()
					ACB->ACB_PATH	:= MsRetPath( M->ACB_OBJETO )
				Endif

				For nLoop := 1 To FCount()
					cCampo := FieldName( nLoop )
					If !( cCampo $ "ACB_FILIAL/ACB_CODOBJ/ACB_PATH" ) .And. Type("M->"+cCampo)<>"U"
						FieldPut( nLoop, M->&cCampo )
					EndIf
				Next nLoop
				ACB->( MsUnlock() )
				While (GetSx8Len() > nSaveSx8)
					ConfirmSX8()
				EndDo
				EvalTrigger()
			Else
				_lContinua := .f.
			Endif
		Else
			_cCodObj := ACB->ACB_CODOBJ
		Endif
	Else
		_cQuery := "SELECT DISTINCT AC9_CODOBJ"
		_cQuery += " FROM " + RetSqlName("SZ2") + " SZ2, " + RetSqlName("AC9") + " AC9 "
		_cQuery += " WHERE Z2_TABID = '" + _cTabID + "'"
		_cQuery += " AND AC9_FILENT = Z2_FILIAL"
		_cQuery += " AND AC9_ENTIDA = 'SZ2'"
		If  Trim(TcGetDb()) = 'ORACLE'
			_cQuery += " AND AC9_CODENT = Z2_FILIAL || Z2_CODTAB"
		Else
			_cQuery += " AND AC9_CODENT = Z2_FILIAL + Z2_CODTAB"
		Endif
		_cQuery += " AND SZ2.D_E_L_E_T_ = ' '"
		_cQuery += " AND AC9.D_E_L_E_T_ = ' '"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasSZ2,.T.,.T.)
		dbSelectArea(cAliasSZ2)
		If !Eof()
			_cCodObj := (cAliasSZ2)->AC9_CODOBJ
		Else
			_lContinua := .F.
		Endif
		(cAliasSZ2)->(dbCloseArea())
	Endif
	If _lContinua
		dbSelectArea("AC9")
		If !dbSeek(xFilial()+_cCodObj+"SZ2"+xFilial("SZ2")+_cChaveAC9)
			RecLock("AC9",.T.)
			Replace AC9_FILIAL with xFilial("AC9"),;
			AC9_FILENT with xFilial("SZ2"),;
			AC9_CODENT with _cChaveAC9,;
			AC9_ENTIDA with "SZ2",;
			AC9_CODOBJ with _cCodObj
			MsUnLock()
		Endif
	Endif
	RestArea(_aAreaZ2)
	RestArea(_aArea)
Return

//--------------------------------------------------------------------------------------------------------
//
Static Function AN_VIEWTAB

	Local _cFilial := SZ2->Z2_FILIAL
	Local _cCodTab := SZ2->Z2_CODTAB
	Local _cDescTab:= SZ2->Z2_DESCTAB
	Local _cMarca  := SZ2->Z2_MARCA
	Local bOk			:= {||}
	oBrowse := FWmBrowse():New()
	oBrowse:SetDataTable(.T.)	//Indica que o Browse utiliza tabela do banco de dados
	oBrowse:SetAlias( 'SZ3' )
	oBrowse:SetDescription("Tabela: " + _cCodTab + " - " + Alltrim(_cDescTab) + Space(10) + "Fornecedor: " + _cMarca)
	oBrowse:AddFilter( "Tabela", "Z3_FILIAL == '" + _cFilial + "' .AND. Z3_CODTAB == '" + _cCodTab + "'", .T., .T.)
	//oBrowse:AddButton("Pedido Encerrar", bOk,,,, .F., 7 )
	oBrowse:SetMenuDef("CADSZ3")
	oBrowse:Activate()
Return

//--------------------------------------------------------------------------------------------------------
//
Static Function SIMUPRV

	Local _cFilial := SZ2->Z2_FILIAL
	Local _cCodTab := SZ2->Z2_CODTAB
	Local _cDescTab:= SZ2->Z2_DESCTAB
	Local _cMarca  := SZ2->Z2_MARCA
	Local _cCodForn:= SZ2->Z2_CODFORN
	Local _cLoja   := SZ2->Z2_LOJA
	Local _aArea   := GetArea()
	Local aSizeAut := MsAdvSize(,.F.)
	Local cAliasSZ3 := "QRYSZ3"
	Local aStruct 	:= {}
	Local cIndTmp
	Local cChave	:= ''
	Local oSZ3TMP
	Local aColumns	:= {}
	Local bOk		:= {||}
	Local bPergunte	:= {||}
	Local oFnt2S  	:= TFont():New("Arial",6 ,15,.T.,.T.,,,,,.F.) 	  //NEGRITO
	Local cAliasTMP := GetNextAlias()
	Local _nPreco
	Local aSeeks	:= {}
	Local _cCodDA0	:= SuperGetMv("AN_TABPRC",.F.,"100")
	Local cCodDA0	:= Alltrim(SuperGetMv("AN_TABPRC",.F.,"100"))

	If(oSZ3TMP <> NIL)
		oSZ3TMP:Delete()
		oSZ3TMP := NIL
	EndIf

	//--- Cria alias temporario baseado na FIV
	Aadd(aStruct, {"TMP_OK"		,"C"	,1							,0													   })
	Aadd(aStruct, {"TMP_COD"	,"C"	,TamSx3("Z3_COD")[1]		,0						, "Produto"			, 100, " " })
	Aadd(aStruct, {"TMP_DESCRI"	,"C"	,TamSx3("B1_DESC")[1]		,0						, "Descrição"		, 100, " " })
	aAdd(aStruct, {"TMP_PRCANT"	,"N"	,TamSx3("Z3_PRCVEN")[1]		,TamSx3("Z3_PRCVEN")[2]	, "Preço Vd Anterior"	, 100, PesqPict("SZ3","Z3_PRCVEN") })
	aAdd(aStruct, {"TMP_PRCREP"	,"N"	,TamSx3("Z3_PRCVEN")[1]		,TamSx3("Z3_PRCVEN")[2]	, "Preço Reposição"	, 100, PesqPict("SZ3","Z3_PRCVEN") })
	aAdd(aStruct, {"TMP_LETRA"	,"C"	,TamSx3("Z3_LETRA")[1]		,0						, "TP"				, 080,  " " })
	aAdd(aStruct, {"TMP_MARGEM"	,"N"	,TamSx3("Z3_MARGEM")[1]		,TamSx3("Z3_MARGEM")[2]	, "Margem (%)"		, 100, PesqPict("SZ3","Z3_MARGEM") })
	aAdd(aStruct, {"TMP_FATOR"	,"N"	,TamSx3("Z3_FATOR")[1]		,TamSx3("Z3_FATOR")[2]	, "Fator"			, 100, PesqPict("SZ3","Z3_FATOR") })
	aAdd(aStruct, {"TMP_PRCBRT"	,"N"	,TamSx3("Z3_PRCVEN")[1]		,TamSx3("Z3_PRCVEN")[2]	, "Preço Vd Bruto"		, 100, PesqPict("SZ3","Z3_PRCVEN") })
	aAdd(aStruct, {"TMP_DESC"	,"N"	,TamSx3("Z3_DESCONT")[1]	,TamSx3("Z3_DESCONT")[2], "Desconto"		, 100, PesqPict("SZ3","Z3_DESCONT") })
	aAdd(aStruct, {"TMP_PRCVEN"	,"N"	,TamSx3("Z3_PRCVEN")[1]		,TamSx3("Z3_PRCVEN")[2]	, "Preço Vd Liquido"	, 100, PesqPict("SZ3","Z3_PRCVEN") })
	aAdd(aStruct, {"TMP_VARIAC"	,"N"	,TamSx3("Z3_MARGEM")[1]		,TamSx3("Z3_MARGEM")[2]	, "Variação (%)"	, 100, PesqPict("SZ3","Z3_MARGEM") })
	aAdd(aStruct, {"TMP_CODTAB"	,"C"	,TamSx3("Z3_CODTAB")[1]		,TamSx3("Z3_CODTAB")[2]	, "Cod. Tabela"		, 100, PesqPict("SZ3","Z3_CODTAB") })

	//-----------------------------------------
	oSZ3TMP := FwTemporaryTable():New(cAliasTmp)
	oSZ3TMP:SetFields(aStruct)
	oSZ3TMP:AddIndex("1",{"TMP_COD"})
	oSZ3TMP:Create()

	cFilAnt := _cFilial
	dbSelectArea("SZ3")
	_cQuery := "SELECT COUNT(*) COUNT "
	_cQuery += "FROM " + RetSqlName("SZ3") + " SZ3, " + RetSqlName("SB1") + " SB1 "
	_cQuery += " WHERE Z3_FILIAL = '" + xFilial("SZ3") + "'"
	_cQuery += " AND Z3_CODTAB = '" + _cCodTab + "'"
	_cQuery += " AND Z3_COD <> ' '"
	_cQuery += " AND SZ3.D_E_L_E_T_ = ' '"
	_cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "'"
	_cQuery += " AND Z3_COD = B1_COD"
	_cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasSZ3,.T.,.T.)
	dbSelectArea(cAliasSZ3)
	nTotalRec := (cAliasSZ3)->COUNT
	dbCloseArea()
	If nTotalRec > 0
		ProcRegua( nTotalRec )
		_cQuery := "SELECT Z3_COD TMP_COD, B1_DESC TMP_DESCRI"
		_cQuery += " , Z3_PRCREP TMP_PRCREP, Z3_LETRA TMP_LETRA, Z3_DESCONT TMP_DESC, Z3_MARGEM TMP_MARGEM,Z3_PRCBRT TMP_PRCBRT, Z3_PRCLIQ TMP_PRCVEN, ZZH_INDICE TMP_FATOR, Z3_CODTAB TMP_CODTAB "
		_cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
		_cQuery += " INNER JOIN " + RetSqlName("SZ3") + " SZ3 ON Z3_FILIAL = '" + xFilial("SZ3") + "' "
		_cQuery += " AND Z3_CODTAB = '" + _cCodTab + "' AND Z3_COD <> ' ' AND SZ3.D_E_L_E_T_ = ' ' AND Z3_COD = B1_COD "
		_cQuery += " LEFT JOIN " + RetSqlName("DA1") + " DA1 ON DA1_FILIAL = '" + xFilial("DA1") + "' AND DA1_CODTAB = '" + _cCodDA0 + "' AND DA1_CODPRO = B1_COD AND DA1.DA1_XTABSQ = '1'"
		_cQuery += " LEFT JOIN " + RetSqlName("ZZH") + " ZZH ON ZZH_FILAN = '" + xFilial("SZ3") + "' AND ZZH_GRUPO = B1_XLINHA AND ZZH_MARCA = B1_XMARCA AND ZZH.D_E_L_E_T_ = ' '"
		_cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ = ' ' "
		_cQuery += " ORDER BY Z3_COD "
		_cQuery := ChangeQuery(_cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasSZ3,.T.,.T.)
		//	Memowrite("C:\TOTVS\Query.txt",_cQuery)
		dbSelectArea(cAliasSZ3)
		While ! (cAliasSZ3)->(Eof())
			_cCod := (cAliasSZ3)->TMP_COD
			IncProc("Calculando Variação de Preço....")
			(cAliasTmp)->(DbAppend())
			For nI := 1 To Len(aStruct)
				nPosDest := (cAliasTmp)->(FieldPos(aStruct[nI,1]))
				nPosOrig := (cAliasSZ3)->(FieldPos(aStruct[nI,1]))
				If nPosDest > 0 .and. nPosOrig > 0
					(cAliasTmp)->(FieldPut(nPosDest,(cAliasSZ3)->(FieldGet(nPosOrig))))
				Endif
			Next nI
			_nPrcAtu 	:= 0
			DbSelectArea("DA1")
			DA1->(DbOrderNickName("DA1SEQ"))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_XTABSQ
			If DA1->(DbSeek(xFilial("SZ3")+cCodDA0+(cAliasSZ3)->TMP_COD))
				While !DA1->(Eof()) .And. xFilial("SZ3")+cCodDA0+(cAliasSZ3)->TMP_COD == DA1->DA1_FILIAL+DA1->DA1_CODTAB+DA1->DA1_CODPRO
					If DA1->DA1_DATVIG <= dDataBase// .and. (Empty(DA1->DA1_DATVIG) .or. DA1->DA1_DATVIG >= dDataBase)
						_nPrcAtu 	:= DA1->DA1_PRCVEN
						Exit
					Endif
					DA1->(dbSkip())
				End
			EndIf
			If _nPrcAtu > 0
				(cAliasTMP)->TMP_PRCANT := _nPrcAtu
				(cAliasTMP)->TMP_VARIAC := Round((((cAliasSZ3)->TMP_PRCVEN - _nPrcAtu) / _nPrcAtu)*100,2)
			Endif
			While !Eof() .and. _cCod == (cAliasSZ3)->TMP_COD
				(cAliasSZ3)->(DbSkip())
			End
		End
		dbSelectArea(cAliasSZ3)
		dbCloseArea()
	Endif
	dbSelectArea(cAliasTMP)
	dbGotop()
	If !Eof() .and. !Bof()
		//----------------MarkBrowse----------------------------------------------------
		For nX := 1 To Len(aStruct)
			If	!aStruct[nX][1] $ "TMP_OK"
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
				aColumns[Len(aColumns)]:SetTitle(aStruct[nX][5])
				aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
				aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
				aColumns[Len(aColumns)]:SetPicture(aStruct[nX][7])
				If aStruct[nX][2] $ "N/D"
					aColumns[Len(aColumns)]:nAlign := 3
				Endif
			EndIf
		Next nX

		oSize := FWDefSize():New(.T.)
		oSize:AddObject( "ALL", 100, 100, .T., .T. )
		oSize:lLateral	:= .F.  // Calculo vertical
		oSize:Process() //executa os calculos

		oDlgNJK := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],"Simulação" , , , , , CLR_BLACK, CLR_WHITE, , , .t. )

		oFwLayer := FwLayer():New()
		oFwLayer:Init( oDlgNJK, .f., .t. )

		oFWLayer:AddLine( 'GRID', 100, .F. )
		oFWLayer:AddCollumn( 'ALL' , 100, .T., 'GRID' )
		oPnFardinho := oFWLayer:GetColPanel( 'ALL', 'GRID' )

		//Criação e instância do browse de fardos de malas

		_oBrwClass := FWMarkBrowse():New()//FWFormBrowse():New()
		_oBrwClass:SetFieldMark("TMP_OK")
		_oBrwClass:SetOwner(oPnFardinho)
		_oBrwClass:SetDataTable(.T.)
		_oBrwClass:SetTemporary(.T.)
		_oBrwClass:SetAlias(cAliasTMP)
		_oBrwClass:bMark     := {||}
		_oBrwClass:bMark     := {||ItmMark(_oBrwClass,cAliasTMP)}
		_oBrwClass:bAllMark  := {||COPMark(_oBrwClass,cAliasTMP)}
		_oBrwClass:SetDescription("Tabela: " + _cCodTab + " - " + Alltrim(_cDescTab) + Space(10) + "Fornecedor: " + _cMarca)
		_oBrwClass:SetProfileID("_oBrwClass")
		_oBrwClass:SetDBFFilter(.T.)
		_oBrwClass:SetUseFilter()
		_oBrwClass:SetColumns(aColumns)
		_oBrwClass:AddButton("Efetivar Tabela" /* Ok */,{|| EFETTAB(cAliasTMP) })
		_oBrwClass:AddButton("Alterar preço  " /* Ok */,{|| U_AltPrc(cAliasTMP) })
		_oBrwClass:DisableDetails()
		_oBrwClass:SetDoubleClick({|| AGRX500NNK(_cNJKTEMP,(_cNJKTEMP)->NJK_ITEM, FwFldGet('NJJ_TABELA'), (_cNJKTEMP)->NJK_CODDES)/* ,_oBrwClass:Refresh()*/ })
		_oBrwClass:SetMenuDef("")
		_oBrwClass:Activate()

		//	_oBrwClass:SetEditCell(.T.) 						//indica que o grid e editavel
		//	_oBrwClass:acolumns[nColEdit]:ledit := .t.
		//	_oBrwClass:acolumns[nColEdit]:bValid := {|| IIF(ValidRes(_cNJKTEMP,(_cNJKTEMP)->NJK_ITEM, (_cNJKTEMP)->NJK_CODDES, (_cNJKTEMP)->NJK_PERDES) ,_oBrwClass:Refresh(),.F.)}

		oDlgNJK:Activate( , , , .t., { || .t. }, ,  )
	Else
		MsgAlert("Não existe produto cadastrado para essa tabela","Produtos")
	Endif
	RestArea(_aArea)
Return

//-------------------------------------------------------------------
Static Function PRCFRNSZ4(oModelGrid)

	Local lRet       := .T.
	Local nLineCYL   := oModelGrid:GetLine()
	Local _cTpDesc   := FwFldGet('Z4_TPDESC')
	Local _cGrupo    := FwFldGet('Z4_GRUPO')
	Local _cSbGrp    := FwFldGet('Z4_SUBGRP')
	Local _cNacImp   := FwFldGet('Z4_NACIMP')
	Local nI         := 0
	Local _cCampo	 := ""
	Local _lValida	 := .F.
	For nI:=1 to 10
		_cCampo := "Z4_DESC" + StrZero(nI,2)
		_nDesconto := FwFldGet(_cCampo)
		If _nDesconto > 0
			_lValida := .T.
			Exit
		Endif
	Next
	If _lValida
		If Empty(_cTpDesc) .or. Empty(_cGrupo) .or. Empty(_cNacImp)
			Help(" ",1,"HELP","CPVAZIO","Favor preencher os campos Nac/Imp., Grupo e Tipo do Desconto no Grid de Desconto por Grupo/SubGrupo ",3,1)
			lRet := .F.
		Endif
	Endif
Return(lRet)

//-------------------------------------------------------------------
Static Function PRCFRNSZ5(oModelGrid)

	Local lRet       := .T.
	Local nLineCYL   := oModelGrid:GetLine()
	Local _cTpDesc   := FwFldGet('Z5_TPDESC')
	Local _cCodRef   := FwFldGet('Z5_CODREF')
	Local nI         := 0
	Local _cCampo	 := ""
	Local _lValida	 := .F.
	For nI:=1 to 10
		_cCampo := "Z5_DESC" + StrZero(nI,2)
		_nDesconto := FwFldGet(_cCampo)
		If _nDesconto > 0
			_lValida := .T.
			Exit
		Endif
	Next
	If _lValida
		If Empty(_cTpDesc) .or. Empty(_cCodRef)
			Help(" ",1,"HELP","CPVAZIO","Favor preencher os campos << Referencia >> e << Tipo >> do Desconto no Grid de Desconto por Produto ",3,1)
			lRet := .F.
		Endif
	Endif
Return(lRet)

//-------------------------------------------------------------------
Static Function PRCFRNSZ6(oModelGrid)

	Local lRet       := .T.
	Local nLineCYL   := oModelGrid:GetLine()
	Local _cNacImp   := FwFldGet('Z6_NACIMP')
	Local nI         := 0
	Local _cCampo	 := ""
	Local _lValida	 := .F.
	For nI:=1 to 10
		_cCampo := "Z6_DESC" + StrZero(nI,2)
		_nDesconto := FwFldGet(_cCampo)
		If _nDesconto > 0
			_lValida := .T.
			Exit
		Endif
	Next
	If _lValida
		If Empty(_cNacImp)
			Help(" ",1,"HELP","CPVAZION","Favor preencher o campo Nac/Imp. ",3,1)
			lRet := .F.
		Endif
	Endif
Return(lRet)
//--------------------------------------------------------------------
//
Static Function PRCFORPOS(oModel)

	Local _lRet := .t.

Return(_lRet)
//------------------------------------------------------------------
//
/*{Protheus.doc}CalcDesc
@author Ricardo Rotta
@since 31/08/2018
@version P12
Gatilho para calculo dos descontos em cascata
*/
//-------------------------------------------------------------------

User Function CalcDesc

	Local oModel     := FwModelActive()
	Local oModelMast :=	oModel:GetModel( 'Z2MASTER' )
	Local oModelDET
	Local nOperation := oModel:GetOperation()
	Local aArea      := GetArea()
	Local _nRet		 := 0
	Local _nDesc	 := 0
	Local _nBase	 := 100
	Local aDesconto  := {0,0,0,0,0,0,0,0,0,0}
	Local nMoeda	 := 1
	Local _cCampo    := Substr(ReadVar(),4,3)
	If _cCampo == "Z4_"
		oModelDET := oModel:GetModel( 'Z4DETAIL' )
		For nY:=1 to 10
			_cCampo := "Z4_DESC" + StrZero(nY,2)
			aDesconto[nY] := oModelDET:GetValue( _cCampo )
		Next
	ElseIf _cCampo == "Z5_"
		oModelDET := oModel:GetModel( 'Z5DETAIL' )
		For nY:=1 to 10
			_cCampo := "Z5_DESC" + StrZero(nY,2)
			aDesconto[nY] := oModelDET:GetValue( _cCampo )
		Next
	ElseIf _cCampo == "Z6_"
		oModelDET := oModel:GetModel( 'Z6DETAIL' )
		For nY:=1 to 10
			_cCampo := "Z6_DESC" + StrZero(nY,2)
			aDesconto[nY] := oModelDET:GetValue( _cCampo )
		Next
	Endif
	If Len(aDesconto) > 0
		_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
		_nRet := _nBase - _nDesc
	Endif
Return(_nRet)
/*
Atualiza os campos de desconto Z4, Z5 e Z6
*/
//-----------------------------------------------------------
User Function AtuDscG4(_cTabela)

	Local _aArea := GetArea()
	Local oModel     := FwModelActive()
	//Local oModelMast :=	oModel:GetModel( 'Z2MASTER' )
	//Local oModelZ3 	 := oModel:GetModel( 'Z3DETAIL' )
	//Local aSaveLine := FWSaveRows()
	Local nOperation := oModel:GetOperation()
	Local _nRet := CDescZ4(.t.,,nOperation)
	RestArea(_aArea)
Return(_nRet)
/*
Atualiza os campos de desconto Z4, Z5 e Z6
*/
//-----------------------------------------------------------
User Function AtuDscG5(_cTabela)

	Local _aArea := GetArea()
	Local oModel     := FwModelActive()
	//Local oModelMast :=	oModel:GetModel( 'Z2MASTER' )
	//Local oModelZ3 	 := oModel:GetModel( 'Z3DETAIL' )
	//Local aSaveLine := FWSaveRows()
	Local nOperation := oModel:GetOperation()
	Local _nRet := CDescZ5(.t.,,nOperation)
	RestArea(_aArea)
Return(_nRet)
/*
Atualiza os campos de desconto Z4, Z5 e Z6
*/
//-----------------------------------------------------------
User Function AtuDscG6(_cTabela)

	Local _aArea := GetArea()
	Local oModel     := FwModelActive()
	//Local oModelMast :=	oModel:GetModel( 'Z2MASTER' )
	//Local oModelZ3 	 := oModel:GetModel( 'Z3DETAIL' )
	//Local aSaveLine := FWSaveRows()
	Local nOperation := oModel:GetOperation()
	Local _nRet := CDescZ6(.t.,,nOperation)
	RestArea(_aArea)
Return(_nRet)

//-----------------------------------------------------------
//
Static Function CDescZ4(_lAtuTot, _lAtuSZ4, nOperation)

	Local _aArea	 := GetArea()
	Local oModel     := FwModelActive()
	Local oModelMast :=	oModel:GetModel( 'Z2MASTER' )
	Local oModelZ4 	 := oModel:GetModel( 'Z4DETAIL' )
	Local _nRet		 := 0
	Local _nDesc	 := 0
	Local I, nI
	Local _aDescZ4	 := {}
	Local _nBase	 := 100
	Local aDesconto  := {0,0,0,0,0,0,0,0,0,0}
	Local nMoeda	 := 1
	Local _cCodTab	 := oModelMast:GetValue( "Z2_CODTAB" )
	Local _cTipoZ4
	Local _cGrpZ4
	Local _cSubGrpZ4
	Local _cNacImp
	Default _lAtuSZ4 := .F.

	If nOperation >= 3 .and. nOperation <= 4 // .and. oModelZ4:GetQtdLine() > 0
		/*
		For nI := 1 to oModelZ4:GetQtdLine()
		oModelZ4:GoLine( nI )
		If !oModelZ4:IsDeleted()
		_nRet := 0
		_cTipoZ4 	:= oModelZ4:GetValue( "Z4_TPDESC" )
		_cGrpZ4  	:= oModelZ4:GetValue( "Z4_GRUPO" )
		_cSubGrpZ4 	:= oModelZ4:GetValue( "Z4_SUBGRP" )
		_cNacImp 	:= oModelZ4:GetValue( "Z4_NACIMP" )
		If !Empty(_cTipoZ4) .and. !Empty(_cGrpZ4)
		For nY:=1 to 10
		_cCZ4 	:= "Z4_DESC" + StrZero(nY,2)
		aDesconto[nY] := oModelZ4:GetValue( _cCZ4 )
		Next
		If Len(aDesconto) > 0
		_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
		_nRet := _nBase - _nDesc
		Endif
		Endif
		If _nRet > 0
		aadd(_aDescZ4, {_cGrpZ4, _cSubGrpZ4, _cNacImp, _cTipoZ4, _nRet})
		Endif
		oModelZ4:SetValue( 'Z4_TOTDESC', _nRet )
		Endif
		Next
		oModelZ4:GoLine( 1 )
		*/

		_nRet := 0
		_cTipoZ4 	:= SZ4->Z4_TPDESC
		_cGrpZ4  	:= SZ4->Z4_GRUPO
		_cSubGrpZ4 	:= SZ4->Z4_SUBGRP
		_cNacImp 	:= SZ4->Z4_NACIMP
		If !Empty(_cTipoZ4) .and. !Empty(_cGrpZ4)
			For nY:=1 to 10
				_cCZ4 	:= "SZ4->Z4_DESC" + StrZero(nY,2)
				aDesconto[nY] := &_cCZ4
			Next
			If Len(aDesconto) > 0
				_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
				_nRet := _nBase - _nDesc
			Endif
		Endif
	Endif
Return(_nRet)


// Calculo do Desconto da SZ5 por produto
Static Function CDescZ5(_lAtuTot, _lAtuSZ5, nOperation)

	Local oModel     := FwModelActive()
	Local oModelMast :=	oModel:GetModel( 'Z2MASTER' )
	Local oModelZ5 	 := oModel:GetModel( 'Z5DETAIL' )
	Local _nRet		 := 0
	Local _nDesc	 := 0
	Local I, nI
	Local _aDescZ5	 := {}
	Local _nBase	 := 100
	Local aDesconto  := {0,0,0,0,0,0,0,0,0,0}
	Local nMoeda	 := 1
	Local _cCodTab	 := oModelMast:GetValue( "Z2_CODTAB" )
	Default _lAtuSZ5 := .F.
	If nOperation >= 3 .and. nOperation <= 4
		/*
		For nI := 1 to oModelZ5:GetQtdLine()
		oModelZ5:GoLine( nI )
		If !oModelZ5:IsDeleted()
		_nRet := 0
		_cTipoZ5 := oModelZ5:GetValue( "Z5_TPDESC" )
		_cCodRef := oModelZ5:GetValue( "Z5_CODREF" )
		If !Empty(_cTipoZ5) .and. !Empty(_cCodRef)
		For nY:=1 to 10
		_cCZ5	:= "Z5_DESC" + StrZero(nY,2)
		aDesconto[nY] := oModelZ5:GetValue( _cCZ5 )
		Next
		If Len(aDesconto) > 0
		_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
		_nRet := _nBase - _nDesc
		Endif
		Endif
		If _nRet > 0
		aadd(_aDescZ5, {_cCodRef, _cTipoZ5, _nRet})
		Endif
		oModelZ5:SetValue( 'Z5_TOTDESC', _nRet )
		Endif
		Next
		oModelZ5:GoLine( 1 )
		*/
		_nRet := 0
		_cTipoZ5 := SZ5->Z5_TPDESC
		_cCodRef := SZ5->Z5_CODREF
		If !Empty(_cTipoZ5) .and. !Empty(_cCodRef)
			For nY:=1 to 10
				_cCZ5	:= "SZ5->Z5_DESC" + StrZero(nY,2)
				aDesconto[nY] := &_cCZ5
			Next
			If Len(aDesconto) > 0
				_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
				_nRet := _nBase - _nDesc
			Endif
		Endif
	Endif
Return(_nRet)

// Calculo do Desconto da SZ6 GERAL
Static Function CDescZ6(_lAtuTot, _lAtuSZ6, nOperation)

	Local oModel     := FwModelActive()
	Local oModelMast :=	oModel:GetModel( 'Z2MASTER' )
	Local oModelZ6 	 := oModel:GetModel( 'Z6DETAIL' )
	Local _nRet		 := 0
	Local _nDesc	 := 0
	Local _aDescZ6	 := {}
	Local I, nI
	Local _nBase	 := 100
	Local aDesconto  := {0,0,0,0,0,0,0,0,0,0}
	Local nMoeda	 := 1
	Local _cCodTab	 := oModelMast:GetValue( "Z2_CODTAB" )
	Default _lAtuSZ6 := .F.
	If nOperation >= 3 .and. nOperation <= 4
		/*
		For nI := 1 to oModelZ6:GetQtdLine()
		oModelZ6:GoLine( nI )
		If !oModelZ6:IsDeleted()
		_cNacImp 	:= oModelZ6:GetValue( 'Z6_NACIMP' )
		For nY:=1 to 10
		_cCZ6	:= "Z6_DESC" + StrZero(nY,2)
		aDesconto[nY] := oModelZ6:GetValue( _cCZ6 )
		Next
		If Len(aDesconto) > 0
		_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
		_nRet := _nBase - _nDesc
		Endif
		If _nRet > 0
		aadd(_aDescZ6, {_cNacImp, _nRet})
		Endif
		oModelZ6:SetValue( 'Z6_TOTDESC', _nRet )
		Endif
		Next
		oModelZ6:GoLine( 1 )
		*/
		_cNacImp	:= SZ6->Z6_NACIMP
		For nY:=1 to 10
			_cCZ6	:= "SZ6->Z6_DESC" + StrZero(nY,2)
			aDesconto[nY] := &_cCZ6
		Next
		If Len(aDesconto) > 0
			_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
			_nRet := _nBase - _nDesc
		Endif
	Endif
Return(_nRet)
//----------------------------------------------------------------------------------------
User Function VlDescPl(_cParam)

	Local _lRet:= .t.
	Local oModel   := FwModelActive()
	Local oModelZ  := IIF(_cParam == "1",oModel:GetModel( 'Z4DETAIL' ), oModel:GetModel( 'Z5DETAIL' ))
	Local _nValor := &(ReadVar())
	Local _cTipoZ  := IIF(_cParam == "1",oModelZ:GetValue( "Z4_TPDESC" ), oModelZ:GetValue( "Z5_TPDESC" ))
	If _nValor > 0
		If Empty(_cTipoZ)
			Help(" ",1,"HELP","TPVAZIO","Favor preencher o campo  Tipo  do Desconto",3,1)
			_lRet := .f.
		Endif
	Endif
Return(_lRet)

//----------------------------------------------------------------------------------------
User Function VldGrpZ4

	Local _lRet:= .t.
	Local _aArea   := GetArea()
	Local oModel   := FwModelActive()
	Local oModelZ4 := oModel:GetModel( 'Z4DETAIL' )
	Local oModelZ2 := oModel:GetModel( 'Z2MASTER' )
	Local _cGrupo  := M->Z4_GRUPO
	Local _cCodTab := oModelZ2:GetValue( "Z2_CODTAB" )
	if !oModelZ4:IsDeleted()
		If !Empty(_cGrupo)
			dbSelectArea("SZ3")
			dbSetOrder(2)
			If !dbSeek(xFilial()+_cCodTab+_cGrupo)
				Help(" ",1,"HELP","GRPNEXIST","Grupo não encontrado na Lista de Preços",3,1)
				_lRet := .f.
			Endif
		Endif
	Endif
	RestArea(_aArea)
Return(_lRet)
//----------------------------------------------------------------------------------------
User Function VldSGpZ4

	Local _lRet:= .t.
	Local _aArea   := GetArea()
	Local oModel   := FwModelActive()
	Local oModelZ4 := oModel:GetModel( 'Z4DETAIL' )
	Local _cSubGrp := M->Z4_SUBGRP
	Local _cGrupo  := FwFldGet('Z4_GRUPO')
	Local _cCodTab := FwFldGet('Z4_CODTAB')
	if !oModelZ4:IsDeleted()
		If !Empty(_cSubGrp)
			dbSelectArea("SZ3")
			dbSetOrder(2)
			If !dbSeek(xFilial()+_cCodTab+_cGrupo+_cSubGrp)
				Help(" ",1,"HELP","SGRPNEXIST","SubGrupo não encontrado na Lista de Preços",3,1)
				_lRet := .f.
			Endif
		Endif
	Endif
	RestArea(_aArea)
Return(_lRet)
//----------------------------------------------------------------------------------------
User Function VldRefZ5

	Local _lRet:= .t.
	Local _aArea   := GetArea()
	Local oModel   := FwModelActive()
	Local oModelZ5 := oModel:GetModel( 'Z5DETAIL' )
	Local _cCodRef := M->Z5_CODREF
	Local _cCodTab := FwFldGet('Z5_CODTAB')
	if !oModelZ5:IsDeleted()
		If !Empty(_cCodRef)
			dbSelectArea("SZ3")
			dbSetOrder(1)
			If !dbSeek(xFilial()+_cCodTab+_cCodRef)
				Help(" ",1,"HELP","CREFNEXIST","Referencia não encontrada na Lista de Preços",3,1)
				_lRet := .f.
			Endif
		Endif
	Endif
	RestArea(_aArea)
Return(_lRet)
//-----------------------------------------------------------------
// Inicializador Padrão Z4_CODTAB
User Function CODTABINI

	Local _cCodTab := CriaVar("Z4_CODTAB",.F.)
	Local oModel   := FwModelActive()
	Local oModelZ2 := oModel:GetModel( 'Z2MASTER' )
	_cCodTab := oModelZ2:GetValue( "Z2_CODTAB" )
Return(_cCodTab)
//-------------------------------------------------

Static Function VldCopTab(_cTabOri, _cDscOri, _cTabDes)

	Local _lRet := .t.
	Local _aArea := GetArea()
	If !Empty(_cTabOri)
		If _cTabOri == _cTabDes
			Help(" ",1,"HELP","NCODTABD","Codigo da tabela de Origem deve ser diferente da tabela de Destino",3,1)
			_lRet := .f.
		Endif
		If _lRet
			dbSelectArea("SZ2")
			dbSetOrder(1)
			If dbSeek(xFilial()+_cTabOri)
				_cDscOri := SZ2->Z2_DESCTAB
			Else
				Help(" ",1,"HELP","NCODTABF","Codigo da tabela não encontrado",3,1)
				_lRet := .f.
			Endif
		Endif
	Else
		_cDscOri := CriaVar("Z2_DESCTAB",.F.)
	Endif
	RestArea(_aArea)
Return(_lRet)

//-------------------------------------------------------------------------
Static Function IniCopPol(_cTabOri, _cTabDes)

	Local _aArea := GetArea()
	If !Empty(_cTabOri) .and. !Empty(_cTabDes)
		ExecApag(cFilAnt,_cTabDes)
		ExecCop(cFilAnt, _cTabOri, cFilAnt, _cTabDes)
	Endif
	oDlgCOP:End()
	RestArea(_aArea)
Return
//-----------------------------------------------------
Static Function ExecCop(cFilOri,_cTabOri, cFilDes, _cTabDes)

	Local _aArea := GetArea()
	Local _aSZ4	 := {}
	Local _aSZ5	 := {}
	Local _aSZ6	 := {}
	Local cFilSav := cFilAnt
	Local _lCop	 := .F.
	Local nZ2Frete := 0
	Local nZ2Icmfr := 0
	Local nZ2despf := 0
	cFilAnt := cFilOri
	//Adicionado por Walter para copiar as informações da SZ2
	dbSelectArea("SZ2")
	dbSetOrder(1)
	dbSeek(xFilial("SZ2")+_cTabOri)
	nZ2Frete := SZ2->Z2_FRETE
	nZ2Icmfr := SZ2->Z2_ICMFRT
	nZ2despf := SZ2->Z2_DESPFIN
	//Fim
	dbSelectArea("SZ4")
	dbSetOrder(1)
	dbSeek(xFilial()+_cTabOri)
	While !Eof() .and. xFilial("SZ4")+_cTabOri == SZ4->(Z4_FILIAL+Z4_CODTAB)
		aadd(_aSZ4,Array(FCount()))
		For j:=1 to FCount()
			If Alltrim(FieldName(j)) == "Z4_CODTAB"
				_aSZ4[Len(_aSZ4),j] := _cTabDes
			ElseIf Alltrim(FieldName(j)) == "Z4_FILIAL"
				_aSZ4[Len(_aSZ4),j] := cFilDes
			Else
				_aSZ4[Len(_aSZ4),j] := SZ4->&(FieldName(j))
			Endif
		Next
		dbSkip()
	End
	dbSelectArea("SZ5")
	dbSetOrder(1)
	dbSeek(xFilial()+_cTabOri)
	While !Eof() .and. xFilial("SZ5")+_cTabOri == SZ5->(Z5_FILIAL+Z5_CODTAB)
		aadd(_aSZ5,Array(FCount()))
		For j:=1 to FCount()
			If Alltrim(FieldName(j)) == "Z5_CODTAB"
				_aSZ5[Len(_aSZ5),j] := _cTabDes
			ElseIf Alltrim(FieldName(j)) == "Z5_FILIAL"
				_aSZ5[Len(_aSZ5),j] := cFilDes
			Else
				_aSZ5[Len(_aSZ5),j] := SZ5->&(FieldName(j))
			Endif
		Next
		dbSkip()
	End
	dbSelectArea("SZ6")
	dbSetOrder(1)
	dbSeek(xFilial()+_cTabOri)
	While !Eof() .and. xFilial("SZ6")+_cTabOri == SZ6->(Z6_FILIAL+Z6_CODTAB)
		aadd(_aSZ6,Array(FCount()))
		For j:=1 to FCount()
			If Alltrim(FieldName(j)) == "Z6_CODTAB"
				_aSZ6[Len(_aSZ6),j] := _cTabDes
			ElseIf Alltrim(FieldName(j)) == "Z6_FILIAL"
				_aSZ6[Len(_aSZ6),j] := cFilDes
			Else
				_aSZ6[Len(_aSZ6),j] := SZ6->&(FieldName(j))
			Endif
		Next
		dbSkip()
	End

	//Adicionado por Walter - Gravar informações na filial destino
	cFilAnt := cFilDes
	dbSelectArea("SZ2")
	dbSetOrder(1)
	If dbSeek(xFilial("SZ2")+_cTabDes)
		RecLock("SZ2",.F.)
		SZ2->Z2_FRETE   := nZ2Frete
		SZ2->Z2_ICMFRT  := nZ2Icmfr
		SZ2->Z2_DESPFIN := nZ2despf
		MsUnlock()
	Endif
	*/
	cFilAnt := cFilOri
	//Fim

	If Len(_aSZ4) > 0
		For nT:=1 to Len(_aSZ4)
			RecLock("SZ4",.T.)
			For j:=1 to FCount()
				FieldPut(j,_aSZ4[nT,j])
			Next
			MsUnLock()
		Next
		_lCop := .T.
	Endif
	If Len(_aSZ5) > 0
		For nT:=1 to Len(_aSZ5)
			RecLock("SZ5",.T.)
			For j:=1 to FCount()
				FieldPut(j,_aSZ5[nT,j])
			Next
			MsUnLock()
		Next
		_lCop := .T.
	Endif
	If Len(_aSZ6) > 0
		For nT:=1 to Len(_aSZ6)
			RecLock("SZ6",.T.)
			For j:=1 to FCount()
				FieldPut(j,_aSZ6[nT,j])
			Next
			MsUnLock()
		Next
		_lCop := .T.
	Endif
	cFilAnt := cFilSav
	RestArea(_aArea)
Return(_lCop)
//-------------------------------------------------------------------------------
Static Function ExecApag(_cFilDes, _cTabDes)

	Local _aArea := GetArea()
	Local _cFilSav := cFilAnt
	cFilAnt := _cFilDes
	dbSelectArea("SZ4")
	dbSetOrder(1)
	dbSeek(xFilial()+_cTabDes)
	While !Eof() .and. xFilial("SZ4")+_cTabDes == SZ4->(Z4_FILIAL+Z4_CODTAB)
		RecLock("SZ4",.F.)
		dbDelete()
		MsUnLock()
		dbSkip()
	End
	dbSelectArea("SZ5")
	dbSetOrder(1)
	dbSeek(xFilial()+_cTabDes)
	While !Eof() .and. xFilial("SZ5")+_cTabDes == SZ5->(Z5_FILIAL+Z5_CODTAB)
		RecLock("SZ5",.F.)
		dbDelete()
		MsUnLock()
		dbSkip()
	End
	dbSelectArea("SZ6")
	dbSetOrder(1)
	dbSeek(xFilial()+_cTabDes)
	While !Eof() .and. xFilial("SZ6")+_cTabDes == SZ6->(Z6_FILIAL+Z6_CODTAB)
		RecLock("SZ6",.F.)
		dbDelete()
		MsUnLock()
		dbSkip()
	End
	cFilAnt := _cFilSav
	RestArea(_aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADMGETFIL ºAutor  ³Rafael Gama         º Data ³  05/06/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adm_Opcoes de pesquisa por filiais existente no cadastro deº±±
±±º          ³ empresa                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Retorno   ³ aSelFil(Contem todas as filiais da empresa selecionada)    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºUso       ³ SIGACTB, SIGAATF, SIGAFIN                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PRCGETFIL(lTodasFil,lSohFilEmp,cAlias,lSohFilUn,lHlp, lExibTela)

	Local cEmpresa 	:= cEmpAnt
	Local cTitulo	:= ""
	Local MvPar		:= ""
	Local MvParDef	:= ""
	Local nI 		:= 0
	Local aArea 	:= GetArea() 					 // Salva Alias Anterior
	Local nReg	    := 0
	Local nSit		:= 0
	Local aSit		:= {}
	Local aSit_Ant	:= {}
	Local aFil 		:= {}
	Local nTamFil	:= Len(xFilial("CT2"))
	Local lDefTop 	:= IIF( FindFunction("IfDefTopCTB"), IfDefTopCTB(), .F.) // verificar se pode executar query (TOPCONN)
	Local nInc		:= 0
	Local aSM0		:= AdmAbreSM0()
	Local aFilAtu	:= {}
	Local lPEGetFil := ExistBlock("CTGETFIL")
	Local lPESetFil := ExistBlock("CTSETFIL")
	Local aFil_Ant
	Local lGestao	:= AdmGetGest()
	Local lFWCompany := FindFunction( "FWCompany" )
	Local cEmpFil 	:= " "
	Local cUnFil	:= " "
	Local nTamEmp	:= 0
	Local nTamUn	:= 0
	Local lOk		:= .T.

	Default lTodasFil 	:= .F.
	Default lSohFilEmp 	:= .F.	//Somente filiais da empresa corrente (Gestao Corporativa)
	Default lSohFilUn 	:= .F.	//Somente filiais da unidade de negocio corrente (Gestao Corporativa)
	Default lHlp		:= .T.
	Default cAlias		:= ""
	Default lExibTela	:= .T.

	/*
	Defines do SM0
	SM0_GRPEMP  // Código do grupo de empresas
	SM0_CODFIL  // Código da filial contendo todos os níveis (Emp/UN/Fil)
	SM0_EMPRESA // Código da empresa
	SM0_UNIDNEG // Código da unidade de negócio
	SM0_FILIAL  // Código da filial
	SM0_NOME    // Nome da filial
	SM0_NOMRED  // Nome reduzido da filial
	SM0_SIZEFIL // Tamanho do campo filial
	SM0_LEIAUTE // Leiaute do grupo de empresas
	SM0_EMPOK   // Empresa autorizada
	SM0_GRPEMP  // Código do grupo de empresas
	SM0_USEROK  // Usuário tem permissão para usar a empresa/filial
	SM0_RECNO   // Recno da filial no SIGAMAT
	SM0_LEIAEMP // Leiaute da empresa (EE)
	SM0_LEIAUN  // Leiaute da unidade de negócio (UU)
	SM0_LEIAFIL // Leiaute da filial (FFFF)
	SM0_STATUS  // Status da filial (0=Liberada para manutenção,1=Bloqueada para manutenção)
	SM0_NOMECOM // Nome Comercial
	SM0_CGC     // CGC
	SM0_DESCEMP // Descricao da Empresa
	SM0_DESCUN  // Descricao da Unidade
	SM0_DESCGRP // Descricao do Grupo
	*/

	//Caso o Alias não seja passado, traz as filiais que o usuario tem acesso (modo padrao)
	lSohFilEmp := IF(Empty(cAlias),.F.,lSohFilEmp)
	lSohFilUN  := IF(Empty(cAlias),.F.,lSohFilUn) .And. lSohFilEmp

	//Caso use gestão corporativa , busca o codigo da empresa dentro do M0_CODFIL
	//Em caso contrario, , traz as filiais que o usuario tem acesso (modo padrao)
	cEmpFil := IIF(lGestao .and. lFwCompany, FWCompany(cAlias)," ")
	cUnFil  := IIF(lGestao .and. lFwCompany, FWUnitBusiness(cAlias)," ")

	//Tamanho do codigo da filial
	nTamEmp := Len(cEmpFil)
	nTamUn  := Len(cUnFil)

	If lDefTop
		If !IsBlind()
			PswOrder(1)
			If PswSeek( __cUserID, .T. )

				aSit		:= {}
				aFilNome	:= {}
				aFilAtu		:= FWArrFilAtu( cEmpresa, cFilAnt )
				If Len( aFilAtu ) > 0
					cTxtAux := IIF(lGestao,"Empresa/Unidade/Filial de ","Filiais de ")
					cTitulo := cTxtAux + AllTrim( aFilAtu[6] )
				EndIf

				// Adiciona as filiais que o usuario tem permissão
				For nInc := 1 To Len( aSM0 )
					//DEFINES da SMO encontra-se no arquivo FWCommand.CH
					//Na função FWLoadSM0(), ela retorna na posicao [SM0_USEROK] se esta filial é válida para o user
					If (aSM0[nInc][SM0_GRPEMP] == cEmpAnt .And. ((ValType(aSM0[nInc][SM0_EMPOK]) == "L" .And. aSM0[nInc][SM0_EMPOK]) .Or. ValType(aSM0[nInc][SM0_EMPOK]) <> "L") .And. aSM0[nInc][SM0_USEROK] )

						//Verificacao se as filiais a serem apresentadas serao
						//Apenas as filiais da empresa conrrente (M0_CODFIL)
						If lGestao .and. lFwCompany .and. lSohFilEmp
							//Se for exclusivo para empresa
							If !Empty(cEmpFil)
								lOk := IIf(cEmpFil == Substr(aSM0[nInc][2],1,nTamEmp),.T.,.F.)
								/*
								Verifica se as filiais devem pertencer a mesma unidade de negocio da filial corrente*/
								If lOk .And. lSohFilUn
									//Se for exclusivo para unidade de negocio
									If !Empty(cUnFil)
										lOk := IIf(cUnFil == Substr(aSM0[nInc][2],nTamEmp + 1,nTamUn),.T.,.F.)
									Endif
								Endif
							Else
								//Se for tudo compartilhado, traz apenas a filial corrente
								lOk := IIf(cFilAnt == aSM0[nInc][SM0_CODFIL],.T.,.F.)
							Endif
						Endif

						If lOk
							AAdd(aSit, {aSM0[nInc][SM0_CODFIL],aSM0[nInc][SM0_NOMRED],Transform(aSM0[nInc][SM0_CGC],PesqPict("SA1","A1_CGC"))})
							MvParDef += aSM0[nInc][SM0_CODFIL]
							nI++
						Endif

						//ponto de entrada para usuario poder manipular as filiais selecionada
						//por exemplo para um usuario especifico poderia adicionar uma filial que normalmente nao tem acesso
						If lPESetFil
							aSit_Ant := aClone(aSit)
							aSit := ExecBlock("CTSETFIL",.F.,.F.,{aSit,nI})

							If aSit == NIL .Or. Empty(aSit) .Or. !Valtype( "aSit" ) <> "A"
								aSit := aClone(aSit_Ant)
							EndIf
							nI := Len(aSit)
						EndIf

					Endif

				Next
				If Len( aSit ) <= 0
					// Se não tem permissão ou ocorreu erro nos dados do usuario, pego a filial corrente.
					Aadd(aSit, aFilAtu[2]+" - "+aFilAtu[7] )
					MvParDef := aFilAtu[2]
					nI++
				EndIf
			EndIf
			If lExibTela
				aFil := {}
				If ExistBlock("ADMSELFIL")	// PE para substituir a AdmOpcoes
					aFil := ExecBlock("ADMSELFIL",.F.,.F.,{cTitulo,aSit,MvParDef,nTamFil})
				ElseIf AdmOpcoes(@MvPar,cTitulo,aSit,MvParDef,,,.F.,nTamFil,nI,.T.,,,,,,,,.T.)  // Chama funcao Adm_Opcoes
					nSit := 1
					For nReg := 1 To len(mvpar) Step nTamFil  // Acumula as filiais num vetor
						If SubSTR(mvpar, nReg, nTamFil) <> Replicate("*",nTamFil)
							AADD(aFil, SubSTR(mvpar, nReg, nTamFil) )
						endif
						nSit++
					next
					If Empty(aFil) .And. lHlp
						Help(" ",1,"ADMFILIAL",,"Por favor selecionar pelo menos uma filial",1,0)		//"Por favor selecionar pelo menos uma filial"
					EndIF

					If Len(aFil) == Len(aSit)
						lTodasFil := .T.
					EndIf
				Endif
			Else
				aFil := aClone(aSit)
			EndIf
		Else
			aFil := {cFilAnt}
		EndIf

		//ponto de entrada para usuario poder manipular as filiais selecionada
		//por exemplo para um usuario especifico poderia adicionar uma filial que normalmente nao tem acesso
		If lExibTela .and. lPEGetFil
			aFil_Ant := aClone(aFil)
			aFil := ExecBlock("CTGETFIL",.F.,.F.,{aFil})
			If aFil == NIL .Or. Empty(aFil)
				aFil := aClone(aFil_Ant)
			EndIf
		EndIf

	Else
		Help("  ",1,"ADMFILTOP",,"Função disponível apenas para ambientes TopConnect",1,0) //"Função disponível apenas para ambientes TopConnect"
	EndIf

	RestArea(aArea)

Return(aFil)
//------------------------------------------------------------------------------
//
User Function MPosFor(_cMarca)

	Local _aArea	:= GetArea()
	Local _aCodForn := {}
	dbSelectArea("ZZM")
	dbSetOrder(2)
	If dbSeek(xFilial("ZZM")+_cMarca)
		_cCodForn := ZZM->ZZM_FORNEC
		_cLoja    := ZZM->ZZM_LOJA
		dbSelectArea("SA2")
		dbSetOrder(1)
		If dbSeek(xFilial("SA2")+_cCodForn+_cLoja)
			aadd(_aCodForn, {SA2->A2_COD, SA2->A2_LOJA})
		Endif
	Endif
	RestArea(_aArea)
Return(_aCodForn)
//-------------------------------------------------------------------
Static Function EFETTAB(cAliasTMP)

	//MBrChgLoop(.F.) //Desabilita a chamada da tela de inclusão novamente.
	Local _aArea := GetArea()
	If MsgYesNo("Confirma a Efetivação da Tabela ?","Atencao")
		MsgRun( "Processando Tabela de Preço..." ,, {||	lRet := AGERATAB(cAliasTMP) } ) //"Processando revisão do Projeto..."
		dbSelectArea("SZ2")
		RecLock("SZ2",.F.)
		Replace Z2_STATUS with '2'
		MsUnLock()
	EndIf
	RestArea(_aArea)
Return

//---------------------------------------------------------------------
Static Function AGERATAB(cAliasTMP)

	Local _aArea := GetArea()
	Local _cCodTab  := SZ2->Z2_CODTAB
	Local _cDescTab := SZ2->Z2_DESCTAB
	Local _cMarca 	:= SZ2->Z2_MARCA
	Local _cItem	:= Replicate("0",TAMSX3("AIB_ITEM")[1])
	Local _aCodForn := u_MPosFor(_cMarca)
	Local nSaveSx8Len := GetSx8Len()
	Local cIdTab
	Local _cCodDA0	:= SuperGetMv("AN_TABPRC",.F.,"100")
	Local _nCount	:= (cAliasTMP)->(reccount())
	Local bCampo := {|nCPO| Field(nCPO) }
	Local nCampos := 1
	Local I := 1
	Local _lGrava := .T.
	Local _lNewDa1 := .F.
	//Walter - 17/01/19
	DbSelectArea(cAliasTMP)
	DbSetOrder(1)
	DbGoTop()
	While (cAliasTMP)->(!Eof())
		If (cAliasTMP)->TMP_OK == _oBrwClass:Mark() .and. (cAliasTMP)->TMP_PRCVEN > 0
			dbSelectArea("DA0")
			dbSetOrder(1)
			If !dbSeek(xFilial()+_cCodDA0)
				RecLock("DA0",.T.)
				Replace DA0_FILIAL with xFilial("DA0"),;
				DA0_CODTAB with _cCodDA0,;
				DA0_DESCRI with "Tabela Generica",;
				DA0_DATDE  with dDataBase,;
				DA0_HORADE with Time(),;
				DA0_HORATE with "23:59",;
				DA0_TPHORA with "1",;
				DA0_ATIVO with "1"
				MsUnLock()
			Endif
			_lGrava := .T.
			dbSelectArea("DA1")
			dbOrderNickName("DA1VG")
			If dbSeek(xFilial()+_cCodDA0+(cAliasTMP)->TMP_COD)
				aDtVig := {}
				_lNewDa1 := .F.
				_dUltVig := Ctod("  /  /  ")
				While !Eof() .and. xFilial("DA1")+_cCodDA0+(cAliasTMP)->TMP_COD == DA1->(DA1_FILIAL+DA1_CODTAB+DA1_CODPRO)
					aadd(aDtVig, DA1->DA1_DATVIG)
					_dUltVig := DA1->DA1_DATVIG
					If dDataBase > DA1->DA1_DATVIG
						_lNewDa1 := .T.
					Endif
					dbSkip()
				End
				If _lNewDa1
					dbSelectArea("DA1")
					dbOrderNickName("DA1VG")
					dbSeek(xFilial()+_cCodDA0+(cAliasTMP)->TMP_COD)
					While !Eof() .and. xFilial("DA1")+_cCodDA0+(cAliasTMP)->TMP_COD == DA1->(DA1_FILIAL+DA1_CODTAB+DA1_CODPRO)
						If DA1->DA1_XTABSQ <= "2"
							RecLock("DA1", .F.)
							Replace DA1_XTABSQ with Soma1(DA1_XTABSQ)
							MsUnLock()
						Else
							RecLock("DA1", .F.)
							dbDelete()
							MsUnLock()
						Endif
						dbSkip()
					End
				Else
					If dbSeek(xFilial()+_cCodDA0+(cAliasTMP)->TMP_COD+Dtos(_dUltVig))
						_lGrava := .F.
						RecLock("DA1",.F.)
						Replace DA1_PRCVEN with (cAliasTMP)->TMP_PRCVEN
						Replace DA1_XPRCBR with (cAliasTMP)->TMP_PRCBRT
						Replace DA1_XPRCLI with (cAliasTMP)->TMP_PRCVEN
						Replace DA1_XPRCRE with (cAliasTMP)->TMP_PRCREP
						Replace DA1_XDESCV with (cAliasTMP)->TMP_DESC
						Replace DA1_XMARGEM with (cAliasTMP)->TMP_MARGEM
						Replace DA1_XFATOR with (cAliasTMP)->TMP_FATOR
						MsUnLock()
					Endif
				Endif
			Endif
			If _lGrava
				RecLock("DA1",.T.)
				Replace DA1_FILIAL with xFilial("DA1")
				Replace DA1_ITEM with Soma1(ProxItem(_cCodDA0))
				Replace DA1_CODTAB with _cCodDA0
				Replace DA1_CODPRO with (cAliasTMP)->TMP_COD
				Replace DA1_PRCVEN with (cAliasTMP)->TMP_PRCVEN
				Replace DA1_ATIVO  with "1"
				Replace DA1_TPOPER with "4"
				Replace DA1_QTDLOT with 999999.99
				Replace DA1_INDLOT with "000000000999999.99"
				Replace DA1_MOEDA with 1
				Replace DA1_DATVIG with dDataBase
				Replace DA1_XLETRA with (cAliasTMP)->TMP_LETRA
				Replace DA1_XCDTAB with _cCodTab
				Replace DA1_XTABSQ with "1"
				Replace DA1_XPRCBR with (cAliasTMP)->TMP_PRCBRT
				Replace DA1_XPRCLI with (cAliasTMP)->TMP_PRCVEN
				Replace DA1_XPRCRE with (cAliasTMP)->TMP_PRCREP
				Replace DA1_XDESCV with (cAliasTMP)->TMP_DESC
				Replace DA1_XMARGEM with (cAliasTMP)->TMP_MARGEM
				Replace DA1_XFATOR with (cAliasTMP)->TMP_FATOR

				MsUnLock()
			Endif
		Endif
		(cAliasTMP)->(DbSkip())
	EndDo
	oDlgNJK:End()
	RestArea(_aArea)
Return
//-------------------------------------------------------------------
Static Function AN_COPPOL

	Local cPerg	:= "AN_COPPOL"
	Local aSelFil 	:= {}
	//Local _aRotAnt	:= aRotina
	Local aSize := MsAdvSize()
	Local aObjects := {{100,100,.t.,.t.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  := MsObjSize(aInfo,aObjects)
	Local cAliasSZ2 := "QRYSZ2"
	Local _cTabOri  := SZ2->Z2_CODTAB
	Local _cFilOri  := SZ2->Z2_FILIAL
	Local aStruct 	:= {}
	Local cIndTmp
	Local cChave	:= ''
	Local _oCopTab
	Local aColumns	:= {}
	Local nRet 		:= 0
	Local bOk 		:= {||((nRet := 1, oMrkBrowse:Deactivate(), oDlgAB:End()))}
	Local bCancel	:= {||((nRet := 0, oMrkBrowse:Deactivate(), oDlgAB:End()))}
	Local oFnt2S  	:= TFont():New("Arial",6 ,15,.T.,.T.,,,,,.F.) 	  //NEGRITO
	Local cAliasTMP  := GetNextAlias()
	Local _lCop		:= .F.
	Local _aFilCop  := {}
	Local _lContinua := .T.//.F.
	Private lEnd := .F.
	/*
	dbSelectArea("SZ4")
	dbSetOrder(1)
	If dbSeek(_cFilOri+_cTabOri)
	_lContinua := .T.
	Endif
	If !_lContinua
	dbSelectArea("SZ5")
	dbSetOrder(1)
	If dbSeek(_cFilOri+_cTabOri)
	_lContinua := .T.
	Endif
	Endif
	If !_lContinua
	dbSelectArea("SZ6")
	dbSetOrder(1)
	If dbSeek(_cFilOri+_cTabOri)
	_lContinua := .T.
	Endif
	Endif
	*/
	If _lContinua
		Gera_SX1(cPerg)
		If Pergunte(cPerg,.T.)
			_cMarca := mv_par01
			_dDtImp	:= mv_par02

			Aadd(aStruct, {"TMP_OK","C",1,0})
			Aadd(aStruct, {"TMP_FILIAL"	,"C"	,TamSx3("Z2_FILIAL")[1]		,0, "Filial"})
			aAdd(aStruct, {"TMP_NOMFIL"	,"C"	,30							,0, "Nome"			, 150, " " })
			Aadd(aStruct, {"TMP_CODTAB"	,"C"	,TamSx3("Z2_CODTAB")[1]		,0, "Tabela"})
			aAdd(aStruct, {"TMP_DESCTA" ,"C"	,TamSx3("Z2_DESCTAB")[1]	,0, "Descrição"		, 150, " " })
			aAdd(aStruct, {"TMP_FORNEC"	,"C"	,TamSx3("Z2_MARCA")[1]		,0, "Fornecedor"	, 100, " " })
			aAdd(aStruct, {"TMP_DTINCL"	,"D"	,TamSx3("Z2_DATA")[1]		,0, "Dt. Inclusão"	, 080,  " " })

			If(_oCopTab <> NIL)
				_oCopTab:Delete()
				_oCopTab := NIL
			EndIf

			_oCopTab := FwTemporaryTable():New(cAliasTmp)
			_oCopTab:SetFields(aStruct)
			_oCopTab:AddIndex("1",{"TMP_FILIAL"}, {"TMP_CODTAB"})
			_oCopTab:Create()

			dbSelectArea("SZ2")
			_cQuery := "SELECT * "
			_cQuery += "FROM " + RetSqlName("SZ2")
			_cQuery += " WHERE Z2_MARCA = '" + _cMarca + "'"
			_cQuery += " AND Z2_DATA = '" + Dtos(_dDtImp) + "'"
			_cQuery += " AND D_E_L_E_T_ = ' '"
			_cQuery += " ORDER BY Z2_FILIAL, Z2_CODTAB"
			_cQuery := ChangeQuery(_cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasSZ2,.T.,.T.)
			dbSelectArea(cAliasSZ2)
			While !Eof()
				If (cAliasSZ2)->Z2_FILIAL <> _cFilOri
					RecLock(cAliasTMP,.T.)
					(cAliasTMP)->TMP_FILIAL := (cAliasSZ2)->Z2_FILIAL
					(cAliasTMP)->TMP_NOMFIL := Posicione("SM0",1,cEmpAnt+(cAliasSZ2)->Z2_FILIAL,"M0_FILIAL")
					(cAliasTMP)->TMP_CODTAB := (cAliasSZ2)->Z2_CODTAB
					(cAliasTMP)->TMP_DESCTAB:= (cAliasSZ2)->Z2_DESCTAB
					(cAliasTMP)->TMP_FORNEC := (cAliasSZ2)->Z2_MARCA
					(cAliasTMP)->TMP_DTINCL := Stod((cAliasSZ2)->Z2_DATA)
					MsUnlock()
				Endif
				dbSelectArea(cAliasSZ2)
				(cAliasSZ2)->(dbSkip())
			End
			dbSelectArea(cAliasSZ2)
			dbCloseArea()
			dbSelectArea(cAliasTMP)
			dbGotop()
			If !Eof() .and. !Bof()
				//----------------MarkBrowse----------------------------------------------------
				For nX := 1 To Len(aStruct)
					If	!aStruct[nX][1] $ "TMP_OK"
						AAdd(aColumns,FWBrwColumn():New())
						aColumns[Len(aColumns)]:lAutosize:=.T.
						aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
						aColumns[Len(aColumns)]:SetTitle(aStruct[nX][5])
						//			aColumns[Len(aColumns)]:SetSize(aStruct[nX][6])
						aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
						//			aColumns[Len(aColumns)]:SetPicture(aStruct[nX][7])
						If aStruct[nX][2] $ "N/D"
							aColumns[Len(aColumns)]:nAlign := 3
						Endif
					EndIf
				Next nX
				aSize := MsAdvSize(,.F.,400)
				DEFINE MSDIALOG oDlgAB TITLE "Selecione Tabela Destino" From 300,0 to 800,1000 OF oMainWnd PIXEL
				oMrkBrowse:= FWMarkBrowse():New()
				oMrkBrowse:SetFieldMark("TMP_OK")
				oMrkBrowse:SetOwner(oDlgAB)
				oMrkBrowse:SetAlias(cAliasTMP)
				oMrkBrowse:AddButton("Confirmar", bOk,,,, .F., 7 ) //Confirmar
				oMrkBrowse:AddButton("Cancelar" ,bCancel,,,, .F., 7 ) //Parâmetros
				//			oMrkBrowse:bMark     := {||}
				oMrkBrowse:bMark     := {||ItmMark(oMrkBrowse,cAliasTMP)}
				oMrkBrowse:bAllMark  := {||COPMark(oMrkBrowse,cAliasTMP)}
				oMrkBrowse:SetDescription("Marque as tabelas que receberão a Politica Comercial selecionada")
				oMrkBrowse:SetColumns(aColumns)
				oMrkBrowse:SetMenuDef("")
				oMrkBrowse:Activate()
				ACTIVATE MSDIALOg oDlgAB CENTERED
			End
			If nRet == 1
				dbSelectArea(cAliasTMP)
				dbGotop()
				While !Eof()
					If (cAliasTMP)->TMP_OK == oMrkBrowse:Mark()
						ExecApag((cAliasTMP)->TMP_FILIAL, (cAliasTMP)->TMP_CODTAB)
						_lCop := ExecCop(_cFilOri,_cTabOri, (cAliasTMP)->TMP_FILIAL, (cAliasTMP)->TMP_CODTAB)
						If _lCop
							aadd(_aFilCop, {(cAliasTMP)->TMP_FILIAL, (cAliasTMP)->TMP_CODTAB})
						Endif
					Endif
					dbSelectArea(cAliasTMP)
					dbSkip()
				End
				If Len(_aFilCop) > 0
					_lRet := MsgYesNo("Politica Comercial copiada, deseja Aplicar a Politica agora ?","Atencao")
					If _lRet
						Processa( {|lEnd| APLICPOL(_aFilCop, @lEnd)}, "Aguarde...","Aplicando Politica Comercial", .T. )
					Endif
				Endif
			Endif
			(cAliasTMP)->(DbCloseArea())
			MSErase(cAliasTMP+GetDbExtension())
			MSErase(cAliasTMP+OrdBagExt())
		Endif
	Else
		Help(" ",1,"HELP","SEMPOLIT","Não encontrado Politica Comercial para a Lista de Preço: " + SZ2->Z2_FILIAL + " / " + SZ2->Z2_CODTAB,3,1)
	Endif
Return
// Função para aplicar a politica comercial
//-----------------------------------------------------------------------------------------------------------------------------------

Static Function APLICPOL(_aFilPol, lEnd)

	Local _aArea := GetArea()
	Local _cFilSav := cFilAnt
	Local nH := 1
	Local cTabPrc
	Local aDesconto := {}
	Local _aDescZ6 := {}
	Local _aDescZ5 := {}
	Local _aDescZ4 := {}
	Local _nBase   := 100
	Local nMoeda   := 1
	Local cAliasSZ3 := "QRYSZ3"
	Local _aCodForn := {}
	Local _aRetCus	:= {}
	Local _cCodDA0	:= SuperGetMv("AN_TABPRC",.F.,"100")
	Local _nValFret := 0
	Local _nVlrFin  := 0

	ProcRegua(Len(_aFilPol))
	For nH:=1 to Len(_aFilPol)
		If lEnd
			Exit
		Endif
		IncProc("Calculando Descontos informados....Filial: " + cFilAnt)
		ProcessMessage() // Minimiza o efeito de 'congelamento' da aplicação

		cFilAnt		:= _aFilPol[nH,1]
		_aDescZ6 	:= PolDescZ6(_aFilPol[nH,2])
		_aDescZ4 	:= PolDescZ4(_aFilPol[nH,2])
		_aDescZ5 	:= PolDescZ5(_aFilPol[nH,2])
		aDesconto	:= {}
		For nI:= 1 to Len(_aDescZ4)
			If lEnd
				Exit
			Endif
			aadd(aDesconto, _aDescZ4[nI,5])
			If _aDescZ4[nI,4] == "A" .and. Len(_aDescZ6) > 0
				_cNacImp := _aDescZ4[nI,3]
				_nPosSZ6 := aScan(_aDescZ6,{|x| x[1] == "A"})
				If _nPosSZ6 == 0
					_nPosSZ6 := aScan(_aDescZ6,{|x| x[1] == _cNacImp})
				Endif
				If _nPosSZ6 > 0
					aadd(aDesconto, _aDescZ6[_nPosSZ6,2])
					_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
					_nRet := _nBase - _nDesc
					_aDescZ4[nI,5] := _nRet
				Endif
			Endif
			aDesconto	:= {}
		Next
		aDesconto	:= {}
		For nI:= 1 to Len(_aDescZ5)
			If lEnd
				Exit
			Endif
			aadd(aDesconto, _aDescZ5[nI,3])
			If _aDescZ5[nI,2] == "A" .and. (Len(_aDescZ6) > 0 .or. Len(_aDescZ5) > 0)
				_cCodRef := _aDescZ5[nI,1]
				dbSelectArea("SZ3")
				dbSetOrder(1)
				If dbSeek(xFilial()+_aFilPol[nH,2]+_cCodRef)
					_cNacImp := SZ3->Z3_NACIMP
					_cGrupo  := SZ3->Z3_GRUPO
					_cSubGrp := SZ3->Z3_SUBGRP
					_nPosSZ6 := aScan(_aDescZ6,{|x| x[1] == "A"})
					_nPosSZ4 := aScan(_aDescZ4,{|x| x[1]+x[2]+x[3] == _cGrupo+_cSubGrp+"A"})
					If _nPosSZ6 == 0
						_nPosSZ6 := aScan(_aDescZ6,{|x| x[1] == _cNacImp})
					Endif
					If _nPosSZ4 == 0
						_nPosSZ4 := aScan(_aDescZ4,{|x| x[1]+x[2]+x[3] == _cGrupo+_cSubGrp+_cNacImp})
					Endif
					If _nPosSZ4 > 0
						aadd(aDesconto, _aDescZ4[_nPosSZ4,5])  // Já foi aplicado o desconto Geral sobre o valor original
					Else
						If _nPosSZ6 > 0
							aadd(aDesconto, _aDescZ6[_nPosSZ6,2])
						Endif
					Endif
					_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
					_nRet := _nBase - _nDesc
					_aDescZ5[nI,3] := _nRet
				Endif
			Endif
			aDesconto	:= {}
		Next
		// Grava os descontos calculados na base
		For nI:= 1 to Len(_aDescZ6)
			If lEnd
				Exit
			Endif
			_cNacImp := _aDescZ6[nI,1]
			_nDesc	 := _aDescZ6[nI,2]
			_cQuery := "UPDATE " + RetSqlName("SZ3") + " SET Z3_DESCONT = " + Alltrim(Str(_nDesc))
			_cQuery += " WHERE Z3_FILIAL = '" + xFilial("SZ3") + "'"
			_cQuery += " AND Z3_CODTAB = '" + _aFilPol[nH,2] + "'"
			If _cNacImp <> "A"
				_cQuery += " AND Z3_NACIMP = '" + _cNacImp + "'"
			Endif
			_cQuery += " AND D_E_L_E_T_ = ' '"
			nErrQry := TCSqlExec( _cQuery )
		Next
		For nI:= 1 to Len(_aDescZ4)
			If lEnd
				Exit
			Endif
			_cGrupo  := _aDescZ4[nI,1]
			_cSubGrp := _aDescZ4[nI,2]
			_cNacImp := _aDescZ4[nI,3]
			_nDesc	 := _aDescZ4[nI,5]
			_cQuery := "UPDATE " + RetSqlName("SZ3") + " SET Z3_DESCONT = " + Alltrim(Str(_nDesc))
			_cQuery += " WHERE Z3_FILIAL = '" + xFilial("SZ3") + "'"
			_cQuery += " AND Z3_CODTAB = '" + _aFilPol[nH,2] + "'"
			If _cNacImp <> "A"
				_cQuery += " AND Z3_NACIMP = '" + _cNacImp + "'"
			Endif
			_cQuery += " AND Z3_GRUPO = '" + _cGrupo + "'"
			_cQuery += " AND Z3_SUBGRP = '" + _cSubGrp + "'"
			_cQuery += " AND D_E_L_E_T_ = ' '"
			nErrQry := TCSqlExec( _cQuery )
		Next
		For nI:= 1 to Len(_aDescZ5)
			If lEnd
				Exit
			Endif
			_cCodRef := _aDescZ5[nI,1]
			_nDesc	 := _aDescZ5[nI,3]
			_cQuery := "UPDATE " + RetSqlName("SZ3") + " SET Z3_DESCONT = " + Alltrim(Str(_nDesc))
			_cQuery += " WHERE Z3_FILIAL = '" + xFilial("SZ3") + "'"
			_cQuery += " AND Z3_CODTAB = '" + _aFilPol[nH,2] + "'"
			_cQuery += " AND Z3_CODREF = '" + _cCodRef + "'"
			_cQuery += " AND D_E_L_E_T_ = ' '"
			nErrQry := TCSqlExec( _cQuery )
		Next
		_cQuery := "UPDATE " + RetSqlName("SZ3") + " SET Z3_PRCLIQ = ROUND(Z3_PRCBRT - (Z3_PRCBRT * Z3_DESCONT/100), 2) "
		_cQuery += " WHERE Z3_FILIAL = '" + xFilial("SZ3") + "'"
		_cQuery += " AND Z3_CODTAB = '" + _aFilPol[nH,2] + "'"
		_cQuery += " AND D_E_L_E_T_ = ' '"
		nErrQry := TCSqlExec( _cQuery )
	Next
	For nH:=1 to Len(_aFilPol)
		If lEnd
			Exit
		Endif
		cFilAnt		:= _aFilPol[nH,1]
		cTabPrc		:= _aFilPol[nH,2]
		dbSelectArea("SZ2")
		dbSetOrder(1)
		If dbSeek(xFilial()+cTabPrc)
			_cCodMarc := SZ2->Z2_MARCA
			_nFrete	  := SZ2->Z2_FRETE
			_nIcmFret := SZ2->Z2_ICMFRT
			_nDespFin := SZ2->Z2_DESPFIN
			_aCodForn := {}
			aadd(_aCodForn, {SZ2->Z2_CODFORN, SZ2->Z2_LOJA})
			dbSelectArea("SZ3")
			_cQuery := "SELECT COUNT(*) REGIST "
			_cQuery += "FROM " + RetSqlName("SZ3")
			_cQuery += " WHERE Z3_FILIAL = '" + xFilial("SZ3") + "'"
			_cQuery += " AND Z3_CODTAB = '" + cTabPrc + "'"
			_cQuery += " AND Z3_COD <> ' '"
			_cQuery += " AND D_E_L_E_T_ = ' '"
			_cQuery := ChangeQuery(_cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasSZ3,.T.,.T.)
			dbSelectArea(cAliasSZ3)
			_nCount := (cAliasSZ3)->REGIST
			dbSelectArea(cAliasSZ3)
			dbCloseArea()
			_cQuery := "SELECT R_E_C_N_O_ RECSZ3 "
			_cQuery += "FROM " + RetSqlName("SZ3")
			_cQuery += " WHERE Z3_FILIAL = '" + xFilial("SZ3") + "'"
			_cQuery += " AND Z3_CODTAB = '" + cTabPrc + "'"
			_cQuery += " AND Z3_COD <> ' '"
			_cQuery += " AND D_E_L_E_T_ = ' '"
			_cQuery := ChangeQuery(_cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasSZ3,.T.,.T.)
			dbSelectArea(cAliasSZ3)
			ProcRegua(_nCount)
			While !Eof() .And. !lEnd
				IncProc("Aplicando politica comercial....Filial: " + cFilAnt)
				ProcessMessage() // Minimiza o efeito de 'congelamento' da aplicação
				_nRecnoZ3	:= (cAliasSZ3)->RECSZ3
				dbSelectArea("SZ3")
				dbGoto(_nRecnoZ3)
				cProduto 	:= SZ3->Z3_COD
				_nPrcTot	:= SZ3->Z3_PRCLIQ
				_cTES		:= SZ3->Z3_TES
				_nAliqIPI	:= SZ3->Z3_IPI
				_nAliqICMS	:= SZ3->Z3_ICMS
				_cLetra		:= SZ3->Z3_LETRA
				_nMargem	:= SZ3->Z3_MARGEM
				_nDescVen	:= SZ3->Z3_DESCVEN
				_nPrcVen	:= SZ3->Z3_PRCVEN
				_nMarKup    := 0
				_nFator 	:= 1
				dbSelectArea("SB1")
				dbSetOrder(1)
				If dbSeek(xFilial()+cProduto)
					_aRetCus := u_AN320CalcT(cProduto, _aCodForn, _nPrcTot, @_cTES, _nAliqIPI, _nAliqICMS, _nFrete, _nIcmFret, _nDespFin)
					_cTES    := _aRetCus[1]
					If !Empty(_cTES)
						_nCusto  := _aRetCus[2]
						_nPisCOF := _aRetCus[3] + _aRetCus[4]
						_nICMRET := _aRetCus[5]
					Else
						_nCusto  := 0
						_nPisCOF := 0
						_nICMRET := 0
					Endif
					_cMonoFas := IIF(SB1->B1_XMONO=="S","S","N")
					_cLinhaSB1  := SB1->B1_XLINHA
					_nMargem  := 0
					_nDescVen := 0
					_nValFret := _aRetCus[6]
					_nVlrFin  := _aRetCus[7]
					dbSelectArea("SBZ")
					dbSetOrder(1)
					If dbSeek(xFilial()+cProduto)
						_cLetra	  := Substr(SBZ->BZ_XLETRA,1,1)
					Endif
					_aRetPrc    := u_CalcPrcV(_cLetra, cProduto, cFilAnt, _nCusto)
					_nMarKup	:= _aRetPrc[1]
					_nLetra		:= _aRetPrc[2]
					_nFator		:= _aRetPrc[3]
					_nPrcVen	:= _aRetPrc[4]
					_nMargem := (1 + (_nMarKup/100)) * _nLetra
					_nMargem := Round((_nMargem - 1) * 100,2)
					_cQuery := "UPDATE " + RetSqlName("SZ3") + " SET Z3_TES = '" + _cTES + "', Z3_PISCOF = " + Alltrim(Str(_nPisCOF)) + ", Z3_PRCREP = " + Alltrim(Str(_nCusto))
					_cQuery += ", Z3_ICMSRET = " + Alltrim(Str(_nICMRET))
					_cQuery += ", Z3_GRTRIB = '" + SB1->B1_GRTRIB + "'"
					_cQuery += ", Z3_LETRA = '" + _cLetra + "'"
					_cQuery += ", Z3_MARGEM = " + Alltrim(Str(_nMargem))
					_cQuery += ", Z3_DESCVEN = " + Alltrim(Str(_nDescVen))
					_cQuery += ", Z3_FATOR = " + Alltrim(Str(_nFator))
					_cQuery += ", Z3_PRCVEN = " + Alltrim(Str(_nPrcVen))
					_cQuery += ", Z3_VALFRET = " + Alltrim(Str(_nValFret))
					_cQuery += ", Z3_VALDFIN = " + Alltrim(Str(_nVlrFin))
					_cQuery += " WHERE Z3_FILIAL = '" + xFilial("SZ3") + "'"
					_cQuery += " AND R_E_C_N_O_ = " + Alltrim(Str(_nRecnoZ3))
					nErrQry := TCSqlExec( _cQuery )
					If nErrQry < 0
						Final("Erro na aplicação da política ", TCSQLError() + _cQuery)
					Endif
				Endif
				dbSelectArea(cAliasSZ3)
				dbSkip()
			End
			dbSelectArea(cAliasSZ3)
			dbCloseArea()
			dbSelectArea("SZ2")
			RecLock("SZ2",.F.)
			Replace Z2_STATUS with "1"
			MsUnLock()
		Endif
	Next
	cFilAnt := _cFilSav
	RestArea(_aArea)
Return
// Função calcular desconto na SZ6 das politicas gravadas
//-----------------------------------------------------------------------------------------------------------------------------------

Static Function PolDescZ6(_cTabela)

	Local _aArea := GetArea()
	Local _nRet  := 0
	Local _nBase := 100
	Local nMoeda   := 1
	Local aDesconto := {}
	Local _aDescZ6 := {}
	dbSelectArea("SZ6")
	dbSetOrder(1)
	dbSeek(xFilial()+_cTabela)
	While !Eof() .and. xFilial("SZ6")+_cTabela == SZ6->(Z6_FILIAL+Z6_CODTAB)
		_cNacImp := SZ6->Z6_NACIMP
		_nRet  := 0
		aDesconto := {}
		For nY:=1 to 10
			_cCZ6	:= "Z6_DESC" + StrZero(nY,2)
			If SZ6->&(_cCZ6) > 0
				aadd(aDesconto, SZ6->&(_cCZ6))
			Endif
		Next
		If Len(aDesconto) > 0
			_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
			_nRet := _nBase - _nDesc
		Endif
		If _nRet > 0
			aadd(_aDescZ6, {_cNacImp, _nRet})
		Endif
		dbSelectArea("SZ6")
		dbSkip()
	End
	RestArea(_aArea)
Return(_aDescZ6)
// Função calcular desconto na SZ6 das politicas gravadas
//-----------------------------------------------------------------------------------------------------------------------------------

Static Function PolDescZ4(_cTabela)

	Local _aArea := GetArea()
	Local _nRet  := 0
	Local _nBase := 100
	Local nMoeda   := 1
	Local aDesconto := {}
	Local _aDescZ4 := {}
	dbSelectArea("SZ4")
	dbSetOrder(1)
	dbSeek(xFilial()+_cTabela)
	While !Eof() .and. xFilial("SZ4")+_cTabela == SZ4->(Z4_FILIAL+Z4_CODTAB)
		_cNacImp := SZ4->Z4_NACIMP
		_cGrupo  := SZ4->Z4_GRUPO
		_cSubGrp := SZ4->Z4_SUBGRP
		_cTpDesc := SZ4->Z4_TPDESC
		_nRet  := 0
		aDesconto := {}
		For nY:=1 to 10
			_cCZ4	:= "Z4_DESC" + StrZero(nY,2)
			If SZ4->&(_cCZ4) > 0
				aadd(aDesconto, SZ4->&(_cCZ4))
			Endif
		Next
		If Len(aDesconto) > 0
			_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
			_nRet := _nBase - _nDesc
		Endif
		If _nRet > 0
			aadd(_aDescZ4, {_cGrupo, _cSubGrp, _cNacImp, _cTpDesc, _nRet})
		Endif
		dbSelectArea("SZ4")
		dbSkip()
	End
	RestArea(_aArea)
Return(_aDescZ4)
// Função calcular desconto na SZ6 das politicas gravadas
//-----------------------------------------------------------------------------------------------------------------------------------

Static Function PolDescZ5(_cTabela)

	Local _aArea := GetArea()
	Local _nRet  := 0
	Local _nBase := 100
	Local nMoeda   := 1
	Local aDesconto := {}
	Local _aDescZ5 := {}
	dbSelectArea("SZ5")
	dbSetOrder(1)
	dbSeek(xFilial()+_cTabela)
	While !Eof() .and. xFilial("SZ5")+_cTabela == SZ5->(Z5_FILIAL+Z5_CODTAB)
		_cTpDesc := SZ5->Z5_TPDESC
		_cCodRef := SZ5->Z5_CODREF
		_nRet  := 0
		aDesconto := {}
		For nY:=1 to 10
			_cCZ5	:= "Z5_DESC" + StrZero(nY,2)
			If SZ5->&(_cCZ5) > 0
				aadd(aDesconto, SZ5->&(_cCZ5))
			Endif
		Next
		If Len(aDesconto) > 0
			_nDesc := FtDescCab(_nBase,aDesconto,nMoeda)
			_nRet := _nBase - _nDesc
		Endif
		If _nRet > 0
			aadd(_aDescZ5, {_cCodRef, _cTpDesc, _nRet})
		Endif
		dbSelectArea("SZ5")
		dbSkip()
	End
	RestArea(_aArea)
Return(_aDescZ5)
/*/{Protheus.doc} SIAFMark
Função para marcar todos os itens da markbrowse.
@author William Matos Gundim Junior
@since 26/11/2014
@version 1.0
/*/
Static Function COPMark(oMrkBrowse,cArqTrab)

	(cArqTrab)->(dbGoTop())
	While !(cArqTrab)->(Eof())
		RecLock(cArqTrab, .F.)
		If (cArqTrab)->TMP_OK == oMrkBrowse:Mark()
			(cArqTrab)->TMP_OK := ' '
		Else
			(cArqTrab)->TMP_OK := oMrkBrowse:Mark()
		EndIf
		MsUnlock()
		(cArqTrab)->(DbSkip())
	End

	oMrkBrowse:oBrowse:Refresh(.T.)
Return .T.
// Função para marcar no browse
//----------------------------------------------------------------------------------------------
Static Function ItmMark(oMrkBrowse,cArqTrab)

	Local nLinha	:= oMrkBrowse:At()
	/*
	RecLock(cArqTrab, .F.)

	If (cArqTrab)->TMP_OK == oMrkBrowse:Mark()
	(cArqTrab)->TMP_OK := oMrkBrowse:Mark()
	Else
	(cArqTrab)->TMP_OK := ' '
	EndIf
	MsUnlock()
	*/
	//oMrkBrowse:Goto(nLinha,.T.)
	//oMrkBrowse:oBrowse:Refresh(.T.)
Return .T.

//-------------------------------------------------------------------
Static Function Gera_SX1(_cPerg)

	Local _aArea := GetArea()
	Local aRegs := {}
	Local i,j

	dbSelectArea("SX1")
	dbSetOrder(1)
	_cPerg := PADR(_cPerg,10)

	//-- Cria as perguntas.
	aAdd(aRegs,{_cPerg,"01","Da Marca           ?","","","mv_ch1","C",70,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"02","Data Importacao de ?","","","mv_ch2","D",08,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{_cPerg,"03","Data Importacao Ate?","","","mv_ch3","D",08,00,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(_cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	RestArea(_aArea)
Return
//------------------------------------------------------------------------------------------------------------
Static Function IMPTabFil(aSelFil, _cTabOri, _cFileTab, oTabTmp)

	Local _aArea	:= GetArea()
	Local cInsert
	Local cSqlRecno := ""
	Local cAliasSZ3 := "RECMAXZ3"
	Local _nMaxRecno:= 0
	Local cFilOri 	:= cFilAnt
	Local _cTabID 	:= NextIDTab("MV_XTABID", "Z2_TABID")
	Local _aCodForn := u_MPosFor(_cCodMarc)
	Local cIdTab
	Local nPosSobp  := 0
	Local nSaveSx8Len  := GetSx8Len()

	//Inicio função sobrepor
	If Len(aLstSobP) > 0 .And. Len(_aCodForn) > 0
		Processa( {|lEnd| EXCLPOL(aLstSobP,.F.)}, "Aguarde...","Excluindo Lista de Preço", .T. )
		For nK:=1 to Len(aLstSobP)
			cFilAnt   := aLstSobP[nK,1]
			cIdTab	  := aLstSobP[nK,2]
			_cDescTab := aLstSobP[nK,3]
			cSqlRecno := "SELECT MAX(R_E_C_N_O_) RECNOZ3 FROM "+RetSqlName("SZ3")
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlRecno),cAliasSZ3,.T.,.T.)
			dbSelectArea(cAliasSZ3)
			If !Eof()
				_nMaxRecno := (cAliasSZ3)->RECNOZ3
			Endif
			_nMaxRecno++
			dbSelectArea(cAliasSZ3)
			dbCloseArea()
			cInsert := " INSERT INTO "+ RetSqlName("SZ3") +" ("
			cInsert +=      " Z3_FILIAL,"		// 1
			cInsert +=      " Z3_COD,"			// 2
			cInsert +=      " Z3_DESCRI,"		// 2
			cInsert +=      " Z3_REFFOR,"		// 2
			cInsert +=      " Z3_TPOPER,"		// 3
			cInsert +=      " Z3_GRTRIB,"		// 4
			cInsert +=      " Z3_PISCOF,"		// 5
			cInsert +=      " Z3_TES,"			// 6
			cInsert +=      " Z3_PRCREP,"		// 7
			cInsert +=      " Z3_ICMSRET,"		// 8
			cInsert +=      " Z3_CODTAB,"		// 9
			cInsert +=      " Z3_MONOFAS,"		// 10
			cInsert +=      " Z3_CODREF,"		// 11
			cInsert +=      " Z3_PRCBRT,"		// 12
			cInsert +=      " Z3_PRCLIQ,"		// 13
			cInsert +=      " Z3_LETRA,"		// 14
			cInsert +=      " Z3_MARGEM,"		// 15
			cInsert +=      " Z3_DESCVEN,"		// 16
			cInsert +=      " Z3_FATOR,"		// 17
			cInsert +=      " Z3_IPI,"			// 18
			cInsert +=      " Z3_ICMS,"			// 19
			cInsert +=      " Z3_NACIMP,"		// 20
			cInsert +=      " Z3_GRUPO,"		// 21
			cInsert +=      " Z3_SUBGRP,"		// 22
			cInsert +=      " D_E_L_E_T_,"		// 23
			cInsert +=      " R_E_C_N_O_)"		// 24
			cInsert +=      " SELECT "
			cInsert +=      " ( '" + cFilAnt + "') Z3_FILIAL, "	// 1
			cInsert +=      " Z3_COD,"			// 2
			cInsert +=      " Z3_DESCRI,"		// 2
			cInsert +=      " Z3_REFFOR,"		// 2
			cInsert +=      " Z3_TPOPER,"		// 3
			cInsert +=      " Z3_GRTRIB,"		// 4
			cInsert +=      " Z3_PISCOF,"		// 5
			cInsert +=      " Z3_TES,"			// 6
			cInsert +=      " Z3_PRCREP,"		// 7
			cInsert +=      " Z3_ICMSRET,"		// 8
			cInsert +=      " ( '" + cIdTab + "') Z3_CODTAB, "	// 9
			cInsert +=      " Z3_MONOFAS,"		// 10
			cInsert +=      " Z3_CODREF,"		// 11
			cInsert +=      " Z3_PRCBRT,"		// 12
			cInsert +=      " Z3_PRCLIQ,"		// 13
			cInsert +=      " Z3_LETRA,"		// 14
			cInsert +=      " Z3_MARGEM,"		// 15
			cInsert +=      " Z3_DESCVEN,"		// 16
			cInsert +=      " Z3_FATOR,"		// 17
			cInsert +=      " Z3_IPI,"			// 18
			cInsert +=      " Z3_ICMS,"			// 19
			cInsert +=      " Z3_NACIMP,"		// 20
			cInsert +=      " Z3_GRUPO,"		// 21
			cInsert +=      " Z3_SUBGRP,"		// 22
			cInsert +=      " D_E_L_E_T_,"		// 23
			cInsert +=      " ( " + Alltrim(Str(_nMaxRecno)) + " + R_E_C_N_O_) R_E_C_N_O_ "		// 24
			cInsert += " FROM "+oTabTmp:GetRealName()
			//Executa a query.
			If TcSqlExec(cInsert) < 0
				Final("Erro na carga da tabela SZ3. ", TCSQLError() + cInsert)
			Else
				dbSelectArea("SZ2")
				RecLock("SZ2",.T.)
				Replace Z2_FILIAL 	with xFilial("SZ2"),;
				Z2_CODTAB 	with cIdTab,;
				Z2_MARCA 	with _cCodMarc,;
				Z2_DATA 	with dDataBase,;
				Z2_DESCTAB 	with _cDescTab,;
				Z2_USUARIO 	with CUSERNAME,;
				Z2_CODFORN 	with _aCodForn[1,1],;
				Z2_LOJA 	with _aCodForn[1,2],;
				Z2_STATUS 	with '3',;
				Z2_ARQUIVO 	with _cFileTab,;
				Z2_TABID 	with _cTabID
				SZ2->(MsUnLock())
				While (GetSx8Len() > nSaveSx8Len)
					ConfirmSX8()
				EndDo
				GrvArqImp(.T., _cFileTab, cIdTab, _cTabID)
			EndIf
		Next
	Endif
	//FIM função sobrepor

	If Len(_aCodForn) > 0 .And. Len(aLstSobP) == 0 //.And. Len(aLstSobP) == 0 - acrescido para incluir apenas quando não for sobrepor
		For nK:=1 to Len(aSelFil)
			cFilAnt := aSelFil[nK]
			cIdTab	:= GetSXENum("SZ2","Z2_CODTAB")
			cSqlRecno := "SELECT MAX(R_E_C_N_O_) RECNOZ3 FROM "+RetSqlName("SZ3")
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlRecno),cAliasSZ3,.T.,.T.)
			dbSelectArea(cAliasSZ3)
			If !Eof()
				_nMaxRecno := (cAliasSZ3)->RECNOZ3
			Endif
			_nMaxRecno++
			dbSelectArea(cAliasSZ3)
			dbCloseArea()
			cInsert := " INSERT INTO "+ RetSqlName("SZ3") +" ("
			cInsert +=      " Z3_FILIAL,"		// 1
			cInsert +=      " Z3_COD,"			// 2
			cInsert +=      " Z3_DESCRI,"		// 2
			cInsert +=      " Z3_REFFOR,"		// 2
			cInsert +=      " Z3_TPOPER,"		// 3
			cInsert +=      " Z3_GRTRIB,"		// 4
			cInsert +=      " Z3_PISCOF,"		// 5
			cInsert +=      " Z3_TES,"			// 6
			cInsert +=      " Z3_PRCREP,"		// 7
			cInsert +=      " Z3_ICMSRET,"		// 8
			cInsert +=      " Z3_CODTAB,"		// 9
			cInsert +=      " Z3_MONOFAS,"		// 10
			cInsert +=      " Z3_CODREF,"		// 11
			cInsert +=      " Z3_PRCBRT,"		// 12
			cInsert +=      " Z3_PRCLIQ,"		// 13
			cInsert +=      " Z3_LETRA,"		// 14
			cInsert +=      " Z3_MARGEM,"		// 15
			cInsert +=      " Z3_DESCVEN,"		// 16
			cInsert +=      " Z3_FATOR,"		// 17
			cInsert +=      " Z3_IPI,"			// 18
			cInsert +=      " Z3_ICMS,"			// 19
			cInsert +=      " Z3_NACIMP,"		// 20
			cInsert +=      " Z3_GRUPO,"		// 21
			cInsert +=      " Z3_SUBGRP,"		// 22
			cInsert +=      " D_E_L_E_T_,"		// 23
			cInsert +=      " R_E_C_N_O_)"		// 24
			cInsert +=      " SELECT "
			cInsert +=      " ( '" + cFilAnt + "') Z3_FILIAL, "	// 1
			cInsert +=      " Z3_COD,"			// 2
			cInsert +=      " Z3_DESCRI,"		// 2
			cInsert +=      " Z3_REFFOR,"		// 2
			cInsert +=      " Z3_TPOPER,"		// 3
			cInsert +=      " Z3_GRTRIB,"		// 4
			cInsert +=      " Z3_PISCOF,"		// 5
			cInsert +=      " Z3_TES,"			// 6
			cInsert +=      " Z3_PRCREP,"		// 7
			cInsert +=      " Z3_ICMSRET,"		// 8
			cInsert +=      " ( '" + cIdTab + "') Z3_CODTAB, "	// 9
			cInsert +=      " Z3_MONOFAS,"		// 10
			cInsert +=      " Z3_CODREF,"		// 11
			cInsert +=      " Z3_PRCBRT,"		// 12
			cInsert +=      " Z3_PRCLIQ,"		// 13
			cInsert +=      " Z3_LETRA,"		// 14
			cInsert +=      " Z3_MARGEM,"		// 15
			cInsert +=      " Z3_DESCVEN,"		// 16
			cInsert +=      " Z3_FATOR,"		// 17
			cInsert +=      " Z3_IPI,"			// 18
			cInsert +=      " Z3_ICMS,"			// 19
			cInsert +=      " Z3_NACIMP,"		// 20
			cInsert +=      " Z3_GRUPO,"		// 21
			cInsert +=      " Z3_SUBGRP,"		// 22
			cInsert +=      " D_E_L_E_T_,"		// 23
			cInsert +=      " ( " + Alltrim(Str(_nMaxRecno)) + " + R_E_C_N_O_) R_E_C_N_O_ "		// 24
			cInsert += " FROM "+oTabTmp:GetRealName()
			//Executa a query.
			If TcSqlExec(cInsert) < 0
				Final("Erro na carga da tabela SZ3. ", TCSQLError() + cInsert)
			Else
				dbSelectArea("SZ2")
				RecLock("SZ2",.T.)
				Replace Z2_FILIAL with xFilial("SZ2"),;
				Z2_CODTAB with cIdTab,;
				Z2_MARCA with _cCodMarc,;
				Z2_DATA with dDataBase,;
				Z2_DESCTAB with _cDescTab,;
				Z2_USUARIO with CUSERNAME,;
				Z2_CODFORN with _aCodForn[1,1],;
				Z2_LOJA with _aCodForn[1,2],;
				Z2_STATUS with '3',;
				Z2_ARQUIVO with _cFileTab,;
				Z2_TABID with _cTabID
				SZ2->(MsUnLock())
				While (GetSx8Len() > nSaveSx8Len)
					ConfirmSX8()
				EndDo
				GrvArqImp(.T., _cFileTab, cIdTab, _cTabID)
				If !Empty(_cTabOri)
					ExecApag(cFilAnt, cIdTab)
					ExecCop(cFilAnt,_cTabOri, cFilAnt, cIdTab)
				Endif
			EndIf
		Next
	Endif
	cFilAnt := cFilOri
	RestArea(_aArea)
Return

//---------------------------------------------------------------------------------------------------
Static Function AN_EXCPRV()

	Local _aArea := GetArea()
	Local _cCodTab := SZ2->Z2_CODTAB
	Local _cMarca  := SZ2->Z2_MARCA
	Local _aCodForn := Array(1,2)
	Local _aFilCop  := {}
	Local aSelFil 	:= {}
	Local aSize := MsAdvSize()
	Local aObjects := {{100,100,.t.,.t.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  := MsObjSize(aInfo,aObjects)
	Local cAliasSZ2 := "QRYSZ2"
	Local aStruct 	:= {}
	Local cIndTmp
	Local cChave	:= ''
	Local _oCopTab
	Local aColumns	:= {}
	Local nRet 		:= 0
	Local bOk 		:= {||((nRet := 1, oMrkBrowse:Deactivate(), oDlgAB:End()))}
	Local bCancel	:= {||((nRet := 0, oMrkBrowse:Deactivate(), oDlgAB:End()))}
	Local oFnt2S  	:= TFont():New("Arial",6 ,15,.T.,.T.,,,,,.F.) 	  //NEGRITO
	Local cAliasTMP  := GetNextAlias()
	Local _lCop		:= .F.
	Local _lContinua := .F.
	Local cPerg := "AN_CALCPR"
	Local _cMarca
	Local _dDtImp
	Local _dDtAte
	Local _cMarcaSel := ""

	Gera_SX1(cPerg)
	If Pergunte(cPerg,.T.)

		_cMarca := Alltrim(mv_par01)
		_dDtImp	:= mv_par02
		_dDtAte	:= mv_par03

		If !Empty(_cMarca)
			While !Empty(_cMarca)
				nPos := AT(";",_cMarca)
				If Empty(_cMarcaSel)
					_cMarcaSel := "('"
				Else
					_cMarcaSel += ",'"
				Endif
				If nPos > 0
					_cMarcaSel += Alltrim(Substr(_cMarca,1,nPos-1)) + "'"
					_cMarca := Substr(_cMarca,nPos+1)
				Else
					_cMarcaSel += Alltrim(_cMarca) + "'"
					Exit
				Endif
			End
			_cMarcaSel += ")"
		Endif

		Aadd(aStruct, {"TMP_OK","C",1,0})
		Aadd(aStruct, {"TMP_FILIAL"	,"C"	,TamSx3("Z2_FILIAL")[1]		,0, "Filial"})
		aAdd(aStruct, {"TMP_NOMFIL"	,"C"	,30							,0, "Nome"			, 150, " " })
		Aadd(aStruct, {"TMP_CODTAB"	,"C"	,TamSx3("Z2_CODTAB")[1]		,0, "Tabela"})
		aAdd(aStruct, {"TMP_DESCTA" ,"C"	,TamSx3("Z2_DESCTAB")[1]	,0, "Descrição"		, 150, " " })
		aAdd(aStruct, {"TMP_FORNEC"	,"C"	,TamSx3("Z2_MARCA")[1]		,0, "Fornecedor"	, 100, " " })
		aAdd(aStruct, {"TMP_DTINCL"	,"D"	,TamSx3("Z2_DATA")[1]		,0, "Dt. Inclusão"	, 080,  " " })

		If(_oCopTab <> NIL)
			_oCopTab:Delete()
			_oCopTab := NIL
		EndIf

		_oCopTab := FwTemporaryTable():New(cAliasTmp)
		_oCopTab:SetFields(aStruct)
		//_oCopTab:AddIndex("1",{"TMP_FILIAL"}, {"TMP_CODTAB"})
		_oCopTab:AddIndex("1",{"TMP_FORNEC"}, {"TMP_DTINCL"},{"TMP_FILIAL"}) //Alterado por solicitação de Eduardo, 28/02/2019 - Walter
		_oCopTab:Create()

		dbSelectArea("SZ2")
		_cQuery := "SELECT * "
		_cQuery += "FROM " + RetSqlName("SZ2")
		_cQuery += " WHERE Z2_DATA >= '" + Dtos(_dDtImp) + "'"
		_cQuery += " AND Z2_DATA   <= '" + Dtos(_dDtAte) + "'"
		If !Empty(_cMarcaSel)
			_cQuery += " AND Z2_MARCA IN " + _cMarcaSel
		Endif
		_cQuery += " AND D_E_L_E_T_ = ' '"
		_cQuery += " ORDER BY Z2_FILIAL, Z2_CODTAB"
		_cQuery := ChangeQuery(_cQuery)
		MemoWrite("D:\Protheus\querys\exclist.txt",_cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasSZ2,.T.,.T.)
		dbSelectArea(cAliasSZ2)
		While !Eof()
			RecLock(cAliasTMP,.T.)
			(cAliasTMP)->TMP_FILIAL := (cAliasSZ2)->Z2_FILIAL
			(cAliasTMP)->TMP_NOMFIL := Posicione("SM0",1,cEmpAnt+(cAliasSZ2)->Z2_FILIAL,"M0_FILIAL")
			(cAliasTMP)->TMP_CODTAB := (cAliasSZ2)->Z2_CODTAB
			(cAliasTMP)->TMP_DESCTAB:= (cAliasSZ2)->Z2_DESCTAB
			(cAliasTMP)->TMP_FORNEC := (cAliasSZ2)->Z2_MARCA
			(cAliasTMP)->TMP_DTINCL := Stod((cAliasSZ2)->Z2_DATA)
			MsUnlock()
			dbSelectArea(cAliasSZ2)
			(cAliasSZ2)->(dbSkip())
		End
		dbSelectArea(cAliasSZ2)
		dbCloseArea()
		dbSelectArea(cAliasTMP)
		dbGotop()
		If !Eof() .and. !Bof()
			//----------------MarkBrowse----------------------------------------------------
			For nX := 1 To Len(aStruct)
				If	!aStruct[nX][1] $ "TMP_OK"
					AAdd(aColumns,FWBrwColumn():New())
					aColumns[Len(aColumns)]:lAutosize:=.T.
					aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
					aColumns[Len(aColumns)]:SetTitle(aStruct[nX][5])
					//			aColumns[Len(aColumns)]:SetSize(aStruct[nX][6])
					aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
					//			aColumns[Len(aColumns)]:SetPicture(aStruct[nX][7])
					If aStruct[nX][2] $ "N/D"
						aColumns[Len(aColumns)]:nAlign := 3
					Endif
				EndIf
			Next nX
			aSize := MsAdvSize(,.F.,400)
			DEFINE MSDIALOG oDlgAB TITLE "Selecione Tabela para Excluir" From 300,0 to 800,1000 OF oMainWnd PIXEL
			oMrkBrowse:= FWMarkBrowse():New()
			oMrkBrowse:SetFieldMark("TMP_OK")
			oMrkBrowse:SetOwner(oDlgAB)
			oMrkBrowse:SetAlias(cAliasTMP)
			oMrkBrowse:AddButton("Confirmar", bOk,,,, .F., 7 ) //Confirmar
			oMrkBrowse:AddButton("Cancelar" ,bCancel,,,, .F., 7 ) //Parâmetros
			oMrkBrowse:bMark     := {||ItmMark(oMrkBrowse,cAliasTMP)}
			oMrkBrowse:bAllMark  := {||COPMark(oMrkBrowse,cAliasTMP)}
			oMrkBrowse:SetDescription("          E X C L U S Ã O   D A   L I S T A   D E   P R E Ç O  - Selecione para Excluir.")
			oMrkBrowse:SetColumns(aColumns)
			oMrkBrowse:SetMenuDef("")
			oMrkBrowse:Activate()
			ACTIVATE MSDIALOg oDlgAB CENTERED
			If nRet == 1
				dbSelectArea(cAliasTMP)
				dbGotop()
				While !Eof()
					If (cAliasTMP)->TMP_OK == oMrkBrowse:Mark()
						aadd(_aFilCop, {(cAliasTMP)->TMP_FILIAL, (cAliasTMP)->TMP_CODTAB})
					Endif
					dbSkip()
				End
				If Len(_aFilCop) > 0
					If MsgYesNo("Confirma Exclusão ?","Atencao")
						Processa( {|lEnd| EXCLPOL(_aFilCop)}, "Aguarde...","Excluindo Lista de Preço", .T. )
					Endif
				Endif
			Endif
		Endif
	Endif
Return
//----------------------------------------------------------------------
Static Function EXCLPOL(_aFilCop,lExcluiPol)

	Local _aArea := GetArea()
	Local _cFilAtu := cFilAnt
	Local nH, _cCodTab
	Default lExcluiPol  := .T.

	For nH:=1 to Len(_aFilCop)
		_cCodTab	:= _aFilCop[nH,2]
		cFilAnt		:= _aFilCop[nH,1]

		_cQuery := "UPDATE " + RetSqlName("SZ2") + " SET  D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"
		_cQuery += " WHERE Z2_FILIAL = '" + xFilial("SZ2") + "'"
		_cQuery += " AND Z2_CODTAB = '" + _cCodTab + "'"
		_cQuery += " AND D_E_L_E_T_ = ' '"
		nErrQry := TCSqlExec( _cQuery )

		_cQuery := "UPDATE " + RetSqlName("SZ3") + " SET  D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"
		_cQuery += " WHERE Z3_FILIAL = '" + xFilial("SZ3") + "'"
		_cQuery += " AND Z3_CODTAB = '" + _cCodTab + "'"
		_cQuery += " AND D_E_L_E_T_ = ' '"
		nErrQry := TCSqlExec( _cQuery )

		If lExcluiPol
			_cQuery := "UPDATE " + RetSqlName("SZ4") + " SET  D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"
			_cQuery += " WHERE Z4_FILIAL = '" + xFilial("SZ4") + "'"
			_cQuery += " AND Z4_CODTAB = '" + _cCodTab + "'"
			_cQuery += " AND D_E_L_E_T_ = ' '"
			nErrQry := TCSqlExec( _cQuery )

			_cQuery := "UPDATE " + RetSqlName("SZ5") + " SET  D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"
			_cQuery += " WHERE Z5_FILIAL = '" + xFilial("SZ5") + "'"
			_cQuery += " AND Z5_CODTAB = '" + _cCodTab + "'"
			_cQuery += " AND D_E_L_E_T_ = ' '"
			nErrQry := TCSqlExec( _cQuery )

			_cQuery := "UPDATE " + RetSqlName("SZ6") + " SET  D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_"
			_cQuery += " WHERE Z6_FILIAL = '" + xFilial("SZ6") + "'"
			_cQuery += " AND Z6_CODTAB = '" + _cCodTab + "'"
			_cQuery += " AND D_E_L_E_T_ = ' '"
			nErrQry := TCSqlExec( _cQuery )
		Endif
	Next
	cFilAnt := _cFilAtu
Return
//----------------------------------------------------------------------
User Function AN_CALCPRV(nTipo)

	Local _aArea := GetArea()
	Local _cCodTab := SZ2->Z2_CODTAB
	Local _cMarca  := SZ2->Z2_MARCA
	Local _aCodForn := Array(1,2)
	Local _aFilCop  := {}
	Local aSelFil 	:= {}
	Local aSize := MsAdvSize()
	Local aObjects := {{100,100,.t.,.t.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  := MsObjSize(aInfo,aObjects)
	Local cAliasSZ2 := "QRYSZ2"
	Local aStruct 	:= {}
	Local cIndTmp
	Local cChave	:= ''
	Local _oCopTab
	Local aColumns	:= {}
	Local nRet 		:= 0
	Local bOk 		:= {||((nRet := 1, oMrkBrowse:Deactivate(), oDlgAB:End()))}
	Local bCancel	:= {||((nRet := 0, oMrkBrowse:Deactivate(), oDlgAB:End()))}
	Local oFnt2S  	:= TFont():New("Arial",6 ,15,.T.,.T.,,,,,.F.) 	  //NEGRITO
	Local cAliasTMP  := GetNextAlias()
	Local _lCop		:= .F.
	Local _lContinua := .F.
	Local cPerg := "AN_CALCPR"
	Local _cMarca
	Local _dDtImp
	Local _dDtAte
	Local _cMarcaSel := ""
	Private lEnd := .F.

	Gera_SX1(cPerg)
	If Pergunte(cPerg,.T.)

		_cMarca := Alltrim(mv_par01)
		_dDtImp	:= mv_par02
		_dDtAte	:= mv_par03

		If !Empty(_cMarca)
			While !Empty(_cMarca)
				nPos := AT(";",_cMarca)
				If Empty(_cMarcaSel)
					_cMarcaSel := "('"
				Else
					_cMarcaSel += ",'"
				Endif
				If nPos > 0
					_cMarcaSel += Alltrim(Substr(_cMarca,1,nPos-1)) + "'"
					_cMarca := Substr(_cMarca,nPos+1)
				Else
					_cMarcaSel += Alltrim(_cMarca) + "'"
					Exit
				Endif
			End
			_cMarcaSel += ")"
		Endif

		Aadd(aStruct, {"TMP_OK","C",1,0})
		Aadd(aStruct, {"TMP_FILIAL"	,"C"	,TamSx3("Z2_FILIAL")[1]		,0, "Filial"})
		aAdd(aStruct, {"TMP_NOMFIL"	,"C"	,30							,0, "Nome"			, 150, " " })
		Aadd(aStruct, {"TMP_CODTAB"	,"C"	,TamSx3("Z2_CODTAB")[1]		,0, "Tabela"})
		aAdd(aStruct, {"TMP_DESCTA" ,"C"	,TamSx3("Z2_DESCTAB")[1]	,0, "Descrição"		, 150, " " })
		aAdd(aStruct, {"TMP_FORNEC"	,"C"	,TamSx3("Z2_MARCA")[1]		,0, "Fornecedor"	, 100, " " })
		aAdd(aStruct, {"TMP_DTINCL"	,"D"	,TamSx3("Z2_DATA")[1]		,0, "Dt. Inclusão"	, 080,  " " })

		If(_oCopTab <> NIL)
			_oCopTab:Delete()
			_oCopTab := NIL
		EndIf

		_oCopTab := FwTemporaryTable():New(cAliasTmp)
		_oCopTab:SetFields(aStruct)
		_oCopTab:AddIndex("1",{"TMP_FILIAL"}, {"TMP_CODTAB"})
		_oCopTab:Create()

		dbSelectArea("SZ2")
		_cQuery := "SELECT * "
		_cQuery += "FROM " + RetSqlName("SZ2")
		_cQuery += " WHERE Z2_DATA >= '" + Dtos(_dDtImp) + "'"
		_cQuery += " AND Z2_DATA   <= '" + Dtos(_dDtAte) + "'"
		If !Empty(_cMarcaSel)
			_cQuery += " AND Z2_MARCA IN " + _cMarcaSel
		Endif
		_cQuery += " AND D_E_L_E_T_ = ' '"
		_cQuery += " ORDER BY Z2_FILIAL, Z2_CODTAB"
		_cQuery := ChangeQuery(_cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasSZ2,.T.,.T.)
		dbSelectArea(cAliasSZ2)
		While !Eof()
			RecLock(cAliasTMP,.T.)
			(cAliasTMP)->TMP_FILIAL := (cAliasSZ2)->Z2_FILIAL
			(cAliasTMP)->TMP_NOMFIL := Posicione("SM0",1,cEmpAnt+(cAliasSZ2)->Z2_FILIAL,"M0_FILIAL")
			(cAliasTMP)->TMP_CODTAB := (cAliasSZ2)->Z2_CODTAB
			(cAliasTMP)->TMP_DESCTAB:= (cAliasSZ2)->Z2_DESCTAB
			(cAliasTMP)->TMP_FORNEC := (cAliasSZ2)->Z2_MARCA
			(cAliasTMP)->TMP_DTINCL := Stod((cAliasSZ2)->Z2_DATA)
			MsUnlock()
			dbSelectArea(cAliasSZ2)
			(cAliasSZ2)->(dbSkip())
		End
		dbSelectArea(cAliasSZ2)
		dbCloseArea()
		dbSelectArea(cAliasTMP)
		dbGotop()
		If !Eof() .and. !Bof()
			//----------------MarkBrowse----------------------------------------------------
			For nX := 1 To Len(aStruct)
				If	!aStruct[nX][1] $ "TMP_OK"
					AAdd(aColumns,FWBrwColumn():New())
					aColumns[Len(aColumns)]:lAutosize:=.T.
					aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
					aColumns[Len(aColumns)]:SetTitle(aStruct[nX][5])
					//			aColumns[Len(aColumns)]:SetSize(aStruct[nX][6])
					aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
					//			aColumns[Len(aColumns)]:SetPicture(aStruct[nX][7])
					If aStruct[nX][2] $ "N/D"
						aColumns[Len(aColumns)]:nAlign := 3
					Endif
				EndIf
			Next nX
			aSize := MsAdvSize(,.F.,400)
			If nTipo == 1
				DEFINE MSDIALOG oDlgAB TITLE "Selecione Tabela para aplicar a Politica Comercial" From 300,0 to 800,1000 OF oMainWnd PIXEL
			Else
				DEFINE MSDIALOG oDlgAB TITLE "Selecione Tabela para ser efetivada" From 300,0 to 800,1000 OF oMainWnd PIXEL
			EndIf
			oMrkBrowse:= FWMarkBrowse():New()
			oMrkBrowse:SetFieldMark("TMP_OK")
			oMrkBrowse:SetOwner(oDlgAB)
			oMrkBrowse:SetAlias(cAliasTMP)
			oMrkBrowse:AddButton("Confirmar", bOk,,,, .F., 7 ) //Confirmar
			oMrkBrowse:AddButton("Cancelar" ,bCancel,,,, .F., 7 ) //Parâmetros
			oMrkBrowse:bMark     := {||ItmMark(oMrkBrowse,cAliasTMP)}
			oMrkBrowse:bAllMark  := {||COPMark(oMrkBrowse,cAliasTMP)}
			If nTipo == 1
				oMrkBrowse:SetDescription("Marque as tabelas para aplicar a Politica Comercial")
			Else
				oMrkBrowse:SetDescription("Selecione Tabela para ser efetivada")
			EndIf
			oMrkBrowse:SetColumns(aColumns)
			oMrkBrowse:SetMenuDef("")
			oMrkBrowse:Activate()
			ACTIVATE MSDIALOg oDlgAB CENTERED
			If nRet == 1
				dbSelectArea(cAliasTMP)
				dbGotop()
				While !Eof()
					If (cAliasTMP)->TMP_OK == oMrkBrowse:Mark()
						aadd(_aFilCop, {(cAliasTMP)->TMP_FILIAL, (cAliasTMP)->TMP_CODTAB})
					Endif
					dbSkip()
				End
				If Len(_aFilCop) > 0
					If nTipo == 1
						Processa( {|lEnd| APLICPOL(_aFilCop, @lEnd)}, "Aguarde...","Aplicando Politica Comercial", .T. )
					Else
						FwMsgRun(Nil,{||AN001(_aFilCop, @lEnd) },Nil,"Aguarde, Efetivando a tabela de preço...")
					EndIF
				Endif
			Endif
		Endif
	Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MA320CalcT³ Autor ³Rodrigo de A. Sartorio ³ Data ³ 30/04/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava o custo de acordo com o calculo dos impostos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AN320CalcT(cProduto, _aCodForn, _nPrcTot, _cTES, _nAliqIPI, _nAliqICMS, _nFrete, _nIcmFret, _nDespFin)

	Static lValICMS  := NIL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Subtrai valores referentes aos Impostos (ICMS/IPI)              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aArea := GetArea()
	Local nIcm := 0,nIpi := 0, nValImp := 0
	Local cClieFor 	:= _aCodForn[1,1]
	Local cLoja 	:= _aCodForn[1,2]
	Local aRefImp   := {}
	Local nItem 	:= 1
	Local _nCusto 	:= 0
	Local _aCusto 	:= {}
	Local nValPS2 	:= 0
	Local nValCF2 	:= 0
	Local _nICMRET  := 0
	Local _aAreaSB1 := SB1->(GetArea())
	Local _nValFret := 0
	Local _cTpOper  := SuperGetMv('MV_XOPREV',.F.,"01")
	Local _nVlrFin  := 0
	Local _cFilOri := cFilAnt
	Default _nPrcTot := 100
	Default _cTES   := CriaVar("F4_CODIGO",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a quais impostos devem ser gravados.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cFilAnt == "020104"
		cFilAnt := "020101"
	Endif

	aRefImp := MaFisRelImp('MT100',{"SD1"})
	If Empty(_cTES)
		//	_cTES := MaTesInt(1,_cTpOper,cClieFor,cLoja,"F",cProduto,"C7_TES")
		_cTES := u_ANTesInt(/*nEntSai*/ 1,/*cTpOper*/ _cTpOper, cClieFor,cLoja,"F",cProduto)
	Endif
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial()+cClieFor+cLoja)
	If !Empty(_cTES)
		dbSelectArea("SF4")
		dbSetOrder(1)
		If dbSeek(xFilial("SF4")+_cTES)
			cCF := SF4->F4_CF
			If !Empty(SF4->F4_VENPRES) .And. SF4->F4_VENPRES <> "1" //Tes configurado para venda presencial nao altera CFOP
				If SA2->A2_EST == SuperGetMV("MV_ESTADO") .AND. SA2->A2_TIPO # "X"
					cCF := "1" + Subs(cCF,2,3)
				ElseIf SA2->A2_TIPO # "X"
					cCF := "2" + Subs(cCF,2,3)
				Else
					cCF := "3" + Subs(cCF,2,3)
				Endif
			EndIf
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1") + cProduto))
				MaFisIni(_aCodForn[1,1],_aCodForn[1,2],"F","N",NIL,,,.F.,"SB1")
				MaFisIniLoad(nItem,{	SB1->B1_COD,;		//IT_PRODUTO
				_cTES,; 			//IT_TES
				"",; 				//IT_CODISS
				1,;					//IT_QUANT
				" ",;			 	//IT_NFORI
				" ",; 				//IT_SERIORI
				SB1->(RecNo()),;	//IT_RECNOSB1
				SF4->(RecNo()),;	//IT_RECNOSF4
				0 ,;	 			//IT_RECORI
				" ",;				//IT_LOTECTL
				" " })				//IT_NUMLOTE

				//Trecho adicionado por Walter - 11/02/2019 - Solicitado para desconsiderar a aliquota informada no produto
				If _nAliqIPI == 0
					_nAliqIPI := 0.00001 //Forçando o mais proximo de zero, para não pegar do cadastro de produto
				Endif
				If _nAliqICMS == 0
					_nAliqICMS := 0.00001 //Forçando o mais proximo de zero, para não pegar do cadastro de produto
				Endif
				//Fim

				MaFisLoad("IT_ALIQICM",_nAliqICMS,nItem)
				MaFisLoad("IT_ALIQIPI",_nAliqIPI,nItem)
				MaFisTes(_cTES,SF4->(RecNo()),nItem)
				MaFisLoad("IT_VALMERC",_nPrcTot,nItem)
				MaFisLoad("IT_PRCUNI",_nPrcTot,nItem)
				If _nFrete > 0
					_nTotIPI := Round(_nPrcTot * (1 + (_nAliqIPI/100)),2)
					_nValFret:= Round(_nTotIPI * _nFrete/100,2)
				Endif
				If _nDespFin > 0
					_nTotIPI := Round(_nPrcTot * (1 + (_nAliqIPI/100)),2)
					_nVlrFin := Round(_nTotIPI * _nDespFin/100,2)
				Endif
				MaFisRecal("",nItem)
				_nICM 	:= MaFisRet(1,"IT_ALIQICM")
				_nIPI 	:= MaFisRet(1,"IT_ALIQIPI")
				_nValIPI := MaFisRet(1,"IT_VALIPI")
				_nValICM := MaFisRet(1,"IT_VALICM")
				_nICMRET := MaFisRet(1,"IT_VALSOL")
				nValPS2 := MaFisRet(nItem,"IT_VALPS2")
				nValCF2 := MaFisRet(nItem,"IT_VALCF2")

				If nValPS2 > 0 .and. _nFrete > 0
					_nAliqPS2 := MaFisRet(1,"IT_ALIQPS2")
					_nAliqCF2 := MaFisRet(1,"IT_ALIQCF2")
					nValPS2   := Round((_nTotIPI+_nValFret) * _nAliqPS2/100,2)
					nValCF2   := Round((_nTotIPI+_nValFret) * _nAliqCF2/100,2)
				Endif
				MaFisEndLoad(1)
				_aCusto := AN103Custo(_nPrcTot, cProduto, SB1->B1_LOCPAD, 1, _nAliqIPI, _nAliqICMS, nValPS2, nValCF2, _nValIPI, _nDespFin)
				_nCusto := _aCusto[1]
				If _nValFret > 0
					_nICMF := _nValFret * _nIcmFret/100
					_nCusto:= _nCusto + _nValFret - _nICMF
				Endif
				MaFisEnd()
			EndIf
		EndIf
	Endif
	If _cFilOri <> cFilAnt
		cFilAnt := _cFilOri
	Endif
	RestArea(_aAreaSB1)
	RestArea(_aArea)
Return{_cTES, _nCusto, nValPS2, nValCF2, _nICMRET, _nValFret, _nVlrFin}
//-------------------------------------------------------------------------------
Static Function AN103Custo(_nValor, cProduto, _cLocal, _nQuant, _nAliqIPI, _nAliqICMS, nValPS2, nValCF2, _nValIPI, _nDespFin)
	Local aCusto	:= {}
	Local aRet		:= {}
	Local nPos		:= 0
	Local nValIV	:= 0
	Local nX		:= 0
	Local nZ		:= 0
	Local nFatorPS2	:= 1
	Local nFatorCF2	:= 1
	Local nValNCalc	:= 0
	Local lCustPad	:= .T.
	Local uRet		:= Nil
	Local lCredICM	:= SuperGetMV("MV_CREDICM", .F., .F.) 	// Parametro que indica o abatimento do credito de ICMS no custo do item, ao utilizar o campo F4_AGREG = "I"
	Local lCredPis	:= SuperGetMV("MV_CREDPIS", .F., .F.)
	Local lCredCof	:= SuperGetMV("MV_CREDCOF", .F., .F.)
	Local lDEDICMA	:= SuperGetMV("MV_DEDICMA", .F., .F.)	// Efetua deducao do ICMS anterior nao calculado pelo sistema
	Local lDedIcmAnt:= .F.
	Local lValCMaj	:= !Empty(MaFisScan("IT_VALCMAJ",.F.))	// Verifica se a MATXFIS possui a referentcia IT_VALCMAJ
	Local lValPMaj	:= !Empty(MaFisScan("IT_VALPMAJ",.F.))	// Verifica se a MATXFIS possui a referentcia IT_VALCMAJ
	Local nItem		:= 1
	Local aDupl     := {}
	Local cTipo		:= "N"
	Local _nValIPI	:= IIF(SF4->F4_IPI == "S", Round(_nValor * _nAliqIPI/100, 2), 0)
	Local _nValICM	:= IIF(SF4->F4_ICM == "S", Round(_nValor * _nAliqICMS/100, 2), 0)
	Local _nAliqICM := AliqIcms("N","E")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o percentual para credito do PIS / COFINS   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( SF4->F4_BCRDPIS )
		nFatorPS2 := SF4->F4_BCRDPIS / 100
	EndIf

	If !Empty( SF4->F4_BCRDCOF )
		nFatorCF2 := SF4->F4_BCRDCOF / 100
	EndIf

	nValPS2 := nValPS2 * nFatorPS2
	nValCF2 := nValCF2 * nFatorCF2

	If SF4->(FieldPos("F4_CRDICMA")) > 0 .And. !Empty(SF4->F4_CRDICMA)
		lDedIcmAnt := SF4->F4_CRDICMA == '1'
	Else
		lDedIcmAnt := lDEDICMA
	EndIf
	If lDedIcmAnt
		nValNCalc := MaFisRet(nItem,"IT_ICMNDES")
	EndIf

	aADD(aCusto,{			_nValor,;
	_nValIPI,;
	_nValICM,;
	SF4->F4_CREDIPI,;
	SF4->F4_CREDICM,;
	" ",;
	" ",;
	cProduto,;
	_cLocal,;
	_nQuant,;
	If(SF4->F4_IPI=="R",_nValIPI,0),;
	SF4->F4_CREDST,;
	MaFisRet(nItem,"IT_VALSOL"),;
	MaRetIncIV(nItem,"1"),;
	SF4->F4_PISCOF,;
	SF4->F4_PISCRED,;
	nValPS2 - (IIf(lValPMaj,MaFisRet(nItem,"IT_VALPMAJ"),0)),;
	nValCF2 - (IIf(lValCMaj,MaFisRet(nItem,"IT_VALCMAJ"),0)),;
	IIf(SF4->F4_ESTCRED > 0,MaFisRet(nItem,"IT_ESTCRED"),0) ,;
	MaFisRet(nItem,"IT_CRPRSIM"),;
	Iif(SF4->F4_CREDST != '2' .And. SF4->F4_ANTICMS == '1',MaFisRet(nItem,"IT_VALANTI"),0),;
	"";
	})

	// *** Parametros do array aCusto ***
	// 1§ Elemento -> Valor Total do Item, j  com rateio do frete
	// 2§ Elemento -> Valor IPI  do Item.
	// 3§ Elemento -> Valor ICMS do Item.
	// 4§ Elemento -> Informacao do TES de Credita ou n„o do IPI.
	// 5§ Elemento -> Informacao do TES de Credita ou n„o do ICMS.
	// 11.Elemento -> IPI atacadista
	//--> Tratamento para Credito do ICMS Solid. ( Incluido 11/05/2000)
	// 12§ Elemento -> Informacao do TES se Credita ou nao o ICMS Solid.(Default:Nao)
	// 13§ Elemento -> Valor do ICMS Solidario
	// 14§ Elemento -> Utilizado por impostos variaveis
	// 15§ Elemento -> Calcula PIS/Cofins
	// 16§ Elemento -> Credita PIS/Cofins
	// 17§ Elemento -> Valor do PIS/Pasep
	// 18§ Elemento -> Valor do Cofins
	// 19§ Elemento -> Valor do Estorno de ICMS (F4_ESTCRED)
	// 20§ Elemento -> Valor do Credito presumido do simples nacional - Estado SC
	// 21§ Elemento -> Valor da antecipacao de ICMS.

	aRet := RetCusEnt(aDupl,aCusto,cTipo)
	If SF4->F4_AGREG == "N"
		For nX := 1 to Len(aRet[1])
			aRet[1][nX] := If(aRet[1][nX]>0,aRet[1][nX],0)
		Next nX
	EndIf

	If _nDespFin > 0
		_nVlrFin := Round((_nValor + _nValIPI) * _nDespFin/100,2)
		aRet[1][1] := aRet[1][1] + _nVlrFin
	Endif
Return aRet[1]
//----------------------------------------------------------------------------------------------

Static Function NextIDTab(cParametro, cField)

	Local cCodAnt := ""
	Local nC      := 0
	While !LockByName("TABPROXSEQ", .T., .F.)
		Sleep(50)
		nC++
		If nC == 60
			nC := 0
		EndIf
	EndDo
	cCodAnt := PadR(GetMv(cParametro), TamSx3(cField)[1])
	If Empty(cCodAnt)
		cCodAnt := Replicate('0',TamSX3(cField)[1])
	EndIf
	cCodAnt := Soma1(cCodAnt,TamSX3(cField)[1])
	PutMv(cParametro,cCodAnt)
	UnLockByName("TABPROXSEQ", .T., .F.)
Return cCodAnt
//--------------------------------------------------------------------------------------------
Static Function LISTPRCDOC()

	Private aRotina	:= MenuDef()
	Private cCadastro	:= OemtoAnsi("Lista de Preços")

	MsDocument('SZ2',SZ2->(Recno()),4)

Return
//-----------------------------------------------------------------------
// Calcula o preco de reposição considerando os dados digitados na tela
User Function FCalcVen()

	Local _cRotina   := Funname()
	Local _lRet		 := .T.
	Local _aArea	 := GetArea()
	If _cRotina == "MNTTABPRC"
		If Alltrim(ReadVar()) == "M->Z3_LETRA"
			FClcVen_B()
		ElseIf Alltrim(ReadVar()) == "M->Z3_DESCVEN"
			FClcVen_C()
		ElseIf Alltrim(ReadVar()) == "M->Z3_PRCREP"
			FClcVen_D()
		Endif
	Else
		FClcVen_A()
	Endif
Return(_lRet)

//-----------------------------------------------------------------------
// Calcula o preco de reposição considerando os dados digitados na tela

Static Function FClcVen_A

	Local _lRet		 := .T.
	Local _aArea	 := GetArea()
	Local oModel 	 := FWModelActive()
	Local oModelZ3	 := IIF(oModel:csource == "CADSZ3", oModel:GetModel( 'SZ3MASTER' ), oModel:GetModel('Z3DETAIL'))
	Local _cCod	 	 := oModelZ3:GetValue( "Z3_COD" )
	Local _nPrcRep	 := oModelZ3:GetValue( "Z3_PRCREP" )
	Local _cLetra 	 := oModelZ3:GetValue( "Z3_LETRA" )
	Local _nMargem 	 := oModelZ3:GetValue( "Z3_MARGEM" )
	Local _nFator 	 := oModelZ3:GetValue( "Z3_FATOR" )
	Local _nDescVen	 := oModelZ3:GetValue( "Z3_DESCVEN" )
	Local _nPrcVen	 := 0

	If _nPrcRep > 0
		_nPrcVen := u_CalcPrcV(_cLetra, _cCod, cFilAnt, _nPrcRep)[4]
		oModelZ3:SetValue( 'Z3_PRCVEN', _nPrcVen )
	Endif
	RestArea(_aArea)
Return(_lRet)
//-----------------------------------------------------------------------
// Calcula o preco de reposição considerando os dados digitados na tela

Static Function FClcVen_B

	Local _lRet		 := .T.
	Local _aArea	 := GetArea()
	Local _nPrcVen	 := 0
	Local _cLetra	 := M->Z3_LETRA
	Local _nLinPr 	 := oGtd0:nAT
	Local _nPosCod   := aScan(aHeadB1,{|x| AllTrim(x[2]) == "B1_COD"})
	Local _cCod		 := oGtd0:aCols[_nLinPr,_nPosCod]
	Local _nLinha 	 := oGtd2:nAT
	Local _nPrcRep	 := oGtd2:aCols[_nLinha,_nPosRep2]
	If _nPrcRep > 0
		_nPrcVen := u_CalcPrcV(_cLetra, _cCod, cFilAnt, _nPrcRep)[4]
		oGtd2:aCols[_nLinha,_nPosLiq2] := _nPrcVen - (_nPrcVen*oGtd2:aCols[_nLinha,_nPosDes2]/100)
		oGtd2:oBrowse:Refresh()
	Endif
	RestArea(_aArea)
Return(_lRet)
//-----------------------------------------------------------------------
// Calcula o preco de reposição considerando os dados digitados na tela

Static Function FClcVen_C

	Local _lRet		 := .T.
	Local _aArea	 := GetArea()
	Local _nDesc	 := M->Z3_DESCVEN
	Local _nLinPr 	 := oGtd0:nAT
	Local _nPosCod   := aScan(aHeadB1,{|x| AllTrim(x[2]) == "B1_COD"})
	Local _cCod		 := oGtd0:aCols[_nLinPr,_nPosCod]
	Local _nPrcVen	 := 0
	Local _nLinha 	 := oGtd2:nAT
	Local _nPrcRep	 := oGtd2:aCols[_nLinha,_nPosRep2]

	If _nPrcRep > 0
		_nPrcVen := u_CalcPrcV(oGtd2:aCols[_nLinha,_nPosLet2], _cCod, cFilAnt, _nPrcRep)[4]
		oGtd2:aCols[_nLinha,_nPosLiq2] := _nPrcVen - (_nPrcVen*_nDesc/100)
		oGtd2:oBrowse:Refresh()
	Endif
	RestArea(_aArea)
Return(_lRet)
//-----------------------------------------------------------------------
// Calcula o preco de reposição considerando os dados digitados na tela

Static Function FClcVen_D

	Local _lRet		 := .T.
	Local _aArea	 := GetArea()
	Local _nPrcVen	 := 0
	Local _nLinPr 	 := oGtd0:nAT
	Local _nPosCod   := aScan(aHeadB1,{|x| AllTrim(x[2]) == "B1_COD"})
	Local _cCod		 := oGtd0:aCols[_nLinPr,_nPosCod]
	Local _nLinha 	 := oGtd2:nAT
	Local _nPrcRep	 := M->Z3_PRCREP
	If _nPrcRep > 0
		_nPrcVen := u_CalcPrcV(oGtd2:aCols[_nLinha,_nPosLet2], _cCod, cFilAnt, _nPrcRep)[4]
		oGtd2:aCols[_nLinha,_nPosLiq2] := _nPrcVen - (_nPrcVen*oGtd2:aCols[_nLinha,_nPosDes2]/100)
		oGtd2:oBrowse:Refresh()
	Endif
	RestArea(_aArea)
Return(_lRet)
//-----------------------------------------------------------------------------
//
User Function RetLetra(_cLetra)

	Local _aArea:= GetArea()
	Local _nRet := 0
	If !Empty(_cLetra)
		_nRet := Posicione("ZZI",1, xFilial("ZZI")+_cLetra, "ZZI->ZZI_MARGEM")
	Endif
	If _nRet == 0
		_nRet := GetMv("MV_XPDLETR",,0)//1
	Endif
	RestArea(_aArea)
Return(_nRet)
//-----------------------------------------------------------------------------
//
User Function RetMarkup(_cCodProdV,  cFilAnt)

	Local _aArea 	:= GetArea()
	Local _nMarKup 	:= 0
	Local _nFator 	:= 0
	Local _cCodMarc
	Local _cLinhaSB1
	Local _cMonoFas
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial()+_cCodProdV)
		_cCodMarc	:= SB1->B1_XMARCA
		_cLinhaSB1	:= SB1->B1_XLINHA
		_cMonoFas 	:= IIF(SB1->B1_XMONO=="S","S","N")
		dbSelectArea("ZZH")
		dbSetOrder(1)
		IF dbSeek(xFilial()+_cCodMarc+_cLinhaSB1+cFilAnt)
			If _cMonoFas == "S"
				_nMarKup  := ZZH->ZZH_MKMNF
			Else
				_nMarKup  := ZZH->ZZH_MKNMNF
			Endif
			_nFator := ZZH->ZZH_INDICE
		Endif
	Endif
	RestArea(_aArea)
Return({_nMarKup, _nFator})
//-----------------------------------------------------------------------------
//
User Function CalcPrcV(_cLetra, _cCodProdV, cFilAnt, _nCusto)

	Local _aArea 	:= GetArea()
	Local _nMargem  := 0
	Local _nPrcVen 	:= 0
	Local _aRetMark := u_RetMarkup(_cCodProdV,  cFilAnt)
	Local _nMarKup  := _aRetMark[1]
	Local _nFator 	:= _aRetMark[2]
	Local _nLetra 	:= u_RetLetra(_cLetra)
	Local _nMargem  := (1 + (_nMarKup/100)) * _nLetra
	Local _nPrcVen 	:= Round(_nCusto * _nMargem * _nFator, 2)
	RestArea(_aArea)
Return({ _nMarKup, _nLetra, _nFator, _nPrcVen, _nMargem})
//--------------------------------------------------------------------------------------------
//
Static Function CarregaTmp(cAliasTmp, aCampos, oTabTmp, _aDados, lRecria)

	Local aAreaAnt  := GetArea()
	Local cQueryAux := ""
	Local cAliasQry := ""
	Local nX        := 0
	Local nStatus   := 0
	Local lRet      := .T.
	Local _cComand	:= ""
	Local _cValue	:= ""
	Local cInsert := " INSERT INTO "+oTabTmp:GetRealName()+" ("
	cInsert +=      " Z3_FILIAL,"		// 1
	cInsert +=      " Z3_COD,"			// 2
	cInsert +=      " Z3_DESCRI,"		// 2
	cInsert +=      " Z3_REFFOR,"		// 2
	cInsert +=      " Z3_TPOPER,"		// 3
	cInsert +=      " Z3_GRTRIB,"		// 4
	cInsert +=      " Z3_PISCOF,"		// 5
	cInsert +=      " Z3_TES,"			// 6
	cInsert +=      " Z3_PRCREP,"		// 7
	cInsert +=      " Z3_ICMSRET,"		// 8
	cInsert +=      " Z3_CODTAB,"		// 9
	cInsert +=      " Z3_MONOFAS,"		// 10
	cInsert +=      " Z3_CODREF,"		// 11
	cInsert +=      " Z3_PRCBRT,"		// 12
	cInsert +=      " Z3_PRCLIQ,"		// 13
	cInsert +=      " Z3_LETRA,"		// 14
	cInsert +=      " Z3_MARGEM,"		// 15
	cInsert +=      " Z3_DESCVEN,"		// 16
	cInsert +=      " Z3_FATOR,"		// 17
	cInsert +=      " Z3_IPI,"			// 18
	cInsert +=      " Z3_ICMS,"			// 19
	cInsert +=      " Z3_NACIMP,"		// 20
	cInsert +=      " Z3_GRUPO,"		// 21
	cInsert +=      " Z3_SUBGRP)"		// 22
	cInsert +=      " VALUES "
	If oTabTmp != Nil
		If lRecria
			oTabTmp:Delete()
			oTabTmp:Create()
		EndIf
		If lRet
			For nI:=1 to Len(_aDados)
				If Trim(TcGetDb()) = 'ORACLE'
					If TcSqlExec(cInsert + _aDados[nI]) < 0
						Final("Erro na carga da tabela SZ3. ", TCSQLError())
					EndIf
				Else
					If nI < Len(_aDados)
						_cValue := _aDados[nI] + ","
					Else
						_cValue := _aDados[nI]
					Endif
					If nI == 1
						_cComand += cInsert + _cValue + ENTER
					Else
						_cComand += _cValue + ENTER
					Endif
				Endif
			Next
			If Trim(TcGetDb()) <> 'ORACLE'
				If TcSqlExec(_cComand) < 0
					Final("Erro na carga da tabela SZ3. ", TCSQLError())
				EndIf
			Endif
		Endif
	EndIf
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------------------------------------------------
//
Static Function ProxItem(_cCodDA0)

	Local _aArea	 := GetArea()
	Local nTentativa := 0
	Local _lExclusiva := .T.
	Local cAliasDA1 := "QRYDA1"
	Local _nUltItem := StrZero(1, TAMSX3("DA1_ITEM")[1])
	While !LockByName("PRXTABIT",.T.,.T.)
		nTentativa ++
		If nTentativa > 99000
			_lExclusiva := .F.
			Exit
		EndIf
	End
	If _lExclusiva
		_cQuery := " SELECT MAX(DA1_ITEM) DA1_ITEM"
		_cQuery += " FROM " + RetSqlName("DA1") + " DA1 "
		_cQuery += " WHERE DA1_FILIAL = '" + xFilial("DA1") + "'"
		_cQuery += " AND DA1_CODTAB = '" + _cCodDA0 + "'"
		_cQuery += " AND DA1.D_E_L_E_T_ = ' '"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasDA1,.T.,.T.)
		dbSelectArea(cAliasDA1)
		If !Eof()
			_nUltItem := (cAliasDA1)->DA1_ITEM
		Endif
		UnLockByName("PRXTABIT",.T.,.T.)
		dbSelectArea(cAliasDA1)
		dbCloseArea()
	Endif
	RestArea(_aArea)
Return(_nUltItem)
//------------------------------------------------------------------------------------------------------------
Static Function RET_ACENT(cExp)

	cExp := StrTran(cExp,"."," ")
	cExp := StrTran(cExp,"'"," ")
	cExp := StrTran(cExp,"ã","a")
	cExp := StrTran(cExp,CHR(10) ," ")
	cExp := StrTran(cExp,CHR(13) ," ")
	cExp := StrTran(cExp,CHR(151)," ")
Return(cExp)
//------------------------------------------------------------------------------------------------------------
Static Function SOBREPOR
	Local _lRet
	Local nLargura := 400
	Local nAltura  := 350
	Local _cFilSel := "Todas Filiais"
	Local _aSelFil := {}
	Local _cTabOri := SZ2->Z2_CODTAB
	Local _cDscOri := SZ2->Z2_DESCTAB

	Local _aArea := GetArea()
	Local _cCodTab := SZ2->Z2_CODTAB
	Local _cMarca  := SZ2->Z2_MARCA
	Local _aCodForn := Array(1,2)
	Local _aFilCop  := {}
	Local aSelFil 	:= {}
	Local aSize := MsAdvSize()
	Local aObjects := {{100,100,.t.,.t.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  := MsObjSize(aInfo,aObjects)
	Local cAliasSZ2 := "QRYSZ2"
	Local aStruct 	:= {}
	Local cIndTmp
	Local cChave	:= ''
	Local _oCopTab
	Local aColumns	:= {}
	Local nRet 		:= 0
	Local bOk 		:= {||((nRet := 1, oMrkBrowse:Deactivate(), oDlgAB:End()))}
	Local bCancel	:= {||((nRet := 0, oMrkBrowse:Deactivate(), oDlgAB:End()))}
	Local oFnt2S  	:= TFont():New("Arial",6 ,15,.T.,.T.,,,,,.F.) 	  //NEGRITO
	Local cAliasTMP  := GetNextAlias()
	Local _lCop		:= .F.
	Local _lContinua := .F.
	Local cPerg := "AN_CALCPR"
	Local _cMarca
	Local _dDtImp
	Local _dDtAte
	Local _cMarcaSel := ""

	aadd(_aSelFil, "Filial Corrente")
	aadd(_aSelFil, "Seleciona Filiais")
	Private _cCodMarc := SZ2->Z2_MARCA
	Private _cNReduz := POSICIONE("ZZM",2,XFILIAL("ZZM")+_cCodMarc,"ZZM_NOMFOR")
	Private _cDescTab := SZ2->Z2_DESCTAB
	Private cFile  := Space(99999)
	Private oDlgWOF

	Gera_SX1(cPerg)
	If Pergunte(cPerg,.T.)

		_cMarca := Alltrim(mv_par01)
		_dDtImp	:= mv_par02
		_dDtAte	:= mv_par03

		If !Empty(_cMarca)
			While !Empty(_cMarca)
				nPos := AT(";",_cMarca)
				If Empty(_cMarcaSel)
					_cMarcaSel := "('"
				Else
					_cMarcaSel += ",'"
				Endif
				If nPos > 0
					_cMarcaSel += Alltrim(Substr(_cMarca,1,nPos-1)) + "'"
					_cMarca := Substr(_cMarca,nPos+1)
				Else
					_cMarcaSel += Alltrim(_cMarca) + "'"
					Exit
				Endif
			End
			_cMarcaSel += ")"
		Endif

		Aadd(aStruct, {"TMP_OK","C",1,0})
		Aadd(aStruct, {"TMP_FILIAL"	,"C"	,TamSx3("Z2_FILIAL")[1]		,0, "Filial"})
		aAdd(aStruct, {"TMP_NOMFIL"	,"C"	,30							,0, "Nome"			, 150, " " })
		Aadd(aStruct, {"TMP_CODTAB"	,"C"	,TamSx3("Z2_CODTAB")[1]		,0, "Tabela"})
		aAdd(aStruct, {"TMP_DESCTA" ,"C"	,TamSx3("Z2_DESCTAB")[1]	,0, "Descrição"		, 150, " " })
		aAdd(aStruct, {"TMP_FORNEC"	,"C"	,TamSx3("Z2_MARCA")[1]		,0, "Fornecedor"	, 100, " " })
		aAdd(aStruct, {"TMP_DTINCL"	,"D"	,TamSx3("Z2_DATA")[1]		,0, "Dt. Inclusão"	, 080,  " " })

		If(_oCopTab <> NIL)
			_oCopTab:Delete()
			_oCopTab := NIL
		EndIf

		_oCopTab := FwTemporaryTable():New(cAliasTmp)
		_oCopTab:SetFields(aStruct)
		_oCopTab:AddIndex("1",{"TMP_FILIAL"}, {"TMP_CODTAB"})
		_oCopTab:Create()

		dbSelectArea("SZ2")
		_cQuery := "SELECT * "
		_cQuery += "FROM " + RetSqlName("SZ2")
		_cQuery += " WHERE Z2_DATA >= '" + Dtos(_dDtImp) + "'"
		_cQuery += " AND Z2_DATA   <= '" + Dtos(_dDtAte) + "'"
		If !Empty(_cMarcaSel)
			_cQuery += " AND Z2_MARCA IN " + _cMarcaSel
		Endif
		_cQuery += " AND D_E_L_E_T_ = ' '"
		_cQuery += " ORDER BY Z2_FILIAL, Z2_CODTAB"
		_cQuery := ChangeQuery(_cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),cAliasSZ2,.T.,.T.)
		dbSelectArea(cAliasSZ2)
		While !Eof()
			RecLock(cAliasTMP,.T.)
			(cAliasTMP)->TMP_FILIAL := (cAliasSZ2)->Z2_FILIAL
			(cAliasTMP)->TMP_NOMFIL := Posicione("SM0",1,cEmpAnt+(cAliasSZ2)->Z2_FILIAL,"M0_FILIAL")
			(cAliasTMP)->TMP_CODTAB := (cAliasSZ2)->Z2_CODTAB
			(cAliasTMP)->TMP_DESCTAB:= (cAliasSZ2)->Z2_DESCTAB
			(cAliasTMP)->TMP_FORNEC := (cAliasSZ2)->Z2_MARCA
			(cAliasTMP)->TMP_DTINCL := Stod((cAliasSZ2)->Z2_DATA)
			MsUnlock()
			dbSelectArea(cAliasSZ2)
			(cAliasSZ2)->(dbSkip())
		End
		dbSelectArea(cAliasSZ2)
		dbCloseArea()
		dbSelectArea(cAliasTMP)
		dbGotop()
		If !Eof() .and. !Bof()
			//----------------MarkBrowse----------------------------------------------------
			For nX := 1 To Len(aStruct)
				If	!aStruct[nX][1] $ "TMP_OK"
					AAdd(aColumns,FWBrwColumn():New())
					aColumns[Len(aColumns)]:lAutosize:=.T.
					aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
					aColumns[Len(aColumns)]:SetTitle(aStruct[nX][5])
					//			aColumns[Len(aColumns)]:SetSize(aStruct[nX][6])
					aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
					//			aColumns[Len(aColumns)]:SetPicture(aStruct[nX][7])
					If aStruct[nX][2] $ "N/D"
						aColumns[Len(aColumns)]:nAlign := 3
					Endif
				EndIf
			Next nX
			aSize := MsAdvSize(,.F.,400)
			DEFINE MSDIALOG oDlgAB TITLE "Selecione Tabela para Excluir" From 300,0 to 800,1000 OF oMainWnd PIXEL
			oMrkBrowse:= FWMarkBrowse():New()
			oMrkBrowse:SetFieldMark("TMP_OK")
			oMrkBrowse:SetOwner(oDlgAB)
			oMrkBrowse:SetAlias(cAliasTMP)
			oMrkBrowse:AddButton("Confirmar", bOk,,,, .F., 7 ) //Confirmar
			oMrkBrowse:AddButton("Cancelar" ,bCancel,,,, .F., 7 ) //Parâmetros
			oMrkBrowse:bMark     := {||ItmMark(oMrkBrowse,cAliasTMP)}
			oMrkBrowse:bAllMark  := {||COPMark(oMrkBrowse,cAliasTMP)}
			oMrkBrowse:SetDescription("          E X C L U S Ã O   D A   L I S T A   D E   P R E Ç O  - Selecione para Excluir.")
			oMrkBrowse:SetColumns(aColumns)
			oMrkBrowse:SetMenuDef("")
			oMrkBrowse:Activate()
			ACTIVATE MSDIALOg oDlgAB CENTERED
			If nRet == 1
				dbSelectArea(cAliasTMP)
				dbGotop()
				While !Eof()
					If (cAliasTMP)->TMP_OK == oMrkBrowse:Mark()
						aadd(_aFilCop, {(cAliasTMP)->TMP_FILIAL, (cAliasTMP)->TMP_CODTAB})
						aadd(aLstSobP, {(cAliasTMP)->TMP_FILIAL, (cAliasTMP)->TMP_CODTAB, (cAliasTMP)->TMP_DESCTAB})
					Endif
					dbSkip()
				End
				If Len(_aFilCop) > 0
					//Tela para importação
					DEFINE DIALOG oDlgWOF TITLE "Seleção Importação" FROM 0, 0 TO 22, 90 SIZE nLargura, nAltura PIXEL //

					//Painel Origem

					oPanelOrigem   := TPanel():New( 005, 005, ,oDlgWOF, , , , , , nLargura-10, nAltura-19, .F.,.T. )
					@ 00,000 SAY oSay  VAR "Informe os Dados da Tabela para sobrepor" OF oPanelOrigem FONT (TFont():New('Arial',0,-13,.T.,.T.)) PIXEL //"Origem"

					@ 10,005 SAY oAcao VAR "Arquivo" OF oPanelOrigem PIXEL //"Arquivo:"
					@ 20,005 MSGET cFile SIZE 140,010 OF oPanelOrigem WHEN .T. PIXEL
					@ 20,150 BUTTON oBtnAvanca PROMPT "Abrir" SIZE 15,12 ACTION (SelectFile()) OF oPanelOrigem PIXEL //"Abrir"
					/*
					@ 43,005 SAY oEmp VAR "Carrega Filiais " OF oPanelOrigem PIXEL //"Arquivo:"
					@ 43,050 COMBOBOX oSelFil VAR _cFilSel ITEMS _aSelFil SIZE 75,15 OF oPanelOrigem PIXEL
					*/
					//Painel com botões
					oPanelBtn := TPanel():New( (nAltura/2)-14, 0, ,oDlgWOF, , , , , , (nLargura/2), 14, .F.,.T. )
					@ 000,((nLargura/2)-122) BUTTON oBtnAvanca PROMPT "Confirmar"  SIZE 60,12 ACTION (VldSele(_cTabOri, _cFilSel)) OF oPanelBtn PIXEL
					@ 000,((nLargura/2)-60)  BUTTON oBtnAvanca PROMPT "Cancelar"   SIZE 60,12 ACTION (oDlgWOF:End()) OF oPanelBtn PIXEL //"Cancelar"

					ACTIVATE MSDIALOG oDlgWOF CENTER

				Endif
				aLstSobP := {}
			Endif
		Endif
	Endif

Return
//---------------------------------------------

User Function AltPrc(cAliasTMP)

	Local oValor
	Local nValor := (cAliasTMP)->TMP_PRCVEN
	Local oTitulo
	Local oSOK
	Local oSCANCEL
	Local lOK   := .F.
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Atualizar Preço" FROM 000, 000  TO 100, 200 COLORS 0, 16777215 PIXEL

	@ 015, 021 MSGET oValor VAR nValor SIZE 056, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
	@ 004, 022 SAY oTitulo PROMPT "Preço Liquido" SIZE 048, 008 OF oDlg COLORS 0, 16777215 PIXEL

	DEFINE SBUTTON oSOK 	FROM 035, 011 TYPE 01 ACTION (lOk := .T., oDlg:End()) OF oDlg ENABLE
	DEFINE SBUTTON oSCANCEL FROM 035, 059 TYPE 02 ACTION (oDlg:End()) OF oDlg ENABLE

	ACTIVATE MSDIALOG oDlg CENTERED

	If lOK
		If RecLock(cAliasTMP,.F.)
			(cAliasTMP)->TMP_PRCVEN := nValor
			MsUnlock()
		Endif
		_oBrwClass:Refresh(.F.)
	Endif

Return

//--------------------------------------
/*/{Protheus.doc} AN001
Efetiva para varias tabelas e filiais
@author felipe.caiado
@since 29/03/2019
@version 1.0

@type function
/*/
//--------------------------------------
Static Function AN001(aFilCop)

	Local nX 		:= 0
	Local nY 		:= 0
	Local nT 		:= 0
	Local cCodDA0	:= SuperGetMv("AN_TABPRC",.F.,"100")
	Local cAliasDA1		:= GetNextAlias()
	Local cAliasITE		:= GetNextAlias()

	For nT:=1 To Len(aFilCop)

		dbSelectArea("DA0")
		DA0->(dbSetOrder(1))
		If !DA0->(DbSeek(aFilCop[nT][1]+cCodDA0))
			RecLock("DA0",.T.)
			DA0->DA0_FILIAL := aFilCop[nT][1]
			DA0->DA0_CODTAB := cCodDA0
			DA0->DA0_DESCRI := "Tabela Generica"
			DA0->DA0_DATDE  := dDataBase
			DA0->DA0_HORADE := Time()
			DA0->DA0_HORATE := "23:59"
			DA0->DA0_TPHORA := "1"
			DA0->DA0_ATIVO 	:= "1"
			MsUnLock()
		Endif

		DbSelectArea("SZ2")
		SZ2->(DbSetOrder(1))
		If SZ2->(DbSeek(aFilCop[nT][1]+aFilCop[nT][2]))

			DbSelectArea("SZ3")
			SZ3->(DbSetOrder(1))
			If SZ3->(DbSeek(aFilCop[nT][1]+aFilCop[nT][2]))

				While !SZ3->(Eof()) .And. aFilCop[nT][1]+aFilCop[nT][2] == SZ3->Z3_FILIAL+SZ3->Z3_CODTAB

					If Empty(SZ3->Z3_COD)
						SZ3->(DbSkip())
						Loop
					EndIf

					lCriaReg := .T.

					cTabProc 	:= ""
					aTabSeq		:= {}
					aTabDel		:= {}

					lAtualiz	:= .F.

					//Posiciona SB1
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+SZ3->Z3_COD))

					//Posiciona ZZH
					DbSelectArea("ZZH")
					ZZH->(DbSetOrder(1))
					ZZH->(DbSeek(xFilial("ZZH")+SB1->B1_XMARCA+SB1->B1_XLINHA+aFilCop[nT][1]))

					DbSelectArea("DA1")
					DA1->(DbOrderNickName("DA1SEQ"))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_XTABSQ
					If DA1->(DbSeek(aFilCop[nT][1]+cCodDA0+SZ3->Z3_COD))

						While !DA1->(Eof()) .And. aFilCop[nT][1]+cCodDA0+SZ3->Z3_COD == DA1->DA1_FILIAL+DA1->DA1_CODTAB+DA1->DA1_CODPRO

							//Verifica se é menor que a tabela 1
							If DA1->DA1_DATVIG > dDatabase

								DA1->(DbSkip())
								Loop

							ElseIf DA1->DA1_DATVIG == dDatabase

								lCriaReg := .F.

								Reclock("DA1",.F.)

								DA1->DA1_XLETRA 	:= SZ3->Z3_LETRA
								DA1->DA1_XCDTAB 	:= SZ3->Z3_CODTAB
								DA1->DA1_XPRCBR 	:= SZ3->Z3_PRCBRT
								DA1->DA1_XPRCLI 	:= SZ3->Z3_PRCVEN
								DA1->DA1_XPRCRE 	:= SZ3->Z3_PRCREP
								DA1->DA1_XDESCV 	:= SZ3->Z3_DESCONT
								DA1->DA1_XMARGEM 	:= SZ3->Z3_MARGEM
								DA1->DA1_XFATOR 	:= ZZH->ZZH_INDICE
								DA1->DA1_PRCVEN 	:= SZ3->Z3_PRCVEN

								DA1->(MsUnlock())

								DA1->(DbSkip())
								Loop

							Else

								If lCriaReg

									lAtualiz := .T.

									If Empty(cTabProc)
										cTabProc := DA1->DA1_XTABSQ
									EndIf

									//Se menor que 2 aumenta um nivel
									If DA1->DA1_XTABSQ <= "2"

										//Adiciona no array para não atrapalhar o while
										aAdd(aTabSeq,{DA1->(Recno()),Soma1(DA1->DA1_XTABSQ)})

									Else// Se 3 deleta

										aAdd(aTabSeq,{DA1->(Recno()),Soma1(DA1->DA1_XTABSQ)})
										aAdd(aTabDel,DA1->(Recno()))
									EndIf

								EndIf

							EndIf

							DA1->(DbSkip())

						EndDo

						If lCriaReg .And. lAtualiz
							//Atualiza as proximas sequencias
							For nY:=1 To Len(aTabSeq)
								DA1->(DbGoTo(aTabSeq[nY][1]))
								Reclock("DA1",.F.)
									DA1->DA1_XTABSQ := aTabSeq[nY][2]
								DA1->(MsUnlock())
							Next nY

							cTabProx := Soma1(cTabProc)

							//Localiza a vigencia da tabela 1
							BeginSQL alias cAliasDA1
							SELECT
								R_E_C_N_O_ RECNUM
							FROM
								%table:DA1% DA1
							WHERE
								DA1_FILIAL = %exp:aFilCop[nT][1]%
								AND DA1_CODPRO = %exp:SZ3->Z3_COD%
								AND DA1_CODTAB = %exp:cCodDA0%
								AND DA1_XTABSQ = %exp:cTabProx%
								AND DA1.%notDel%
							EndSql

							//Estrutura da DA1
							aStruct := DA1->(DbStruct())

							aReg := {}

							nA := 0

							////Localiza o ultimo item da tabela
							BeginSQL alias cAliasITE
							SELECT
								MAX(DA1_ITEM) DA1_ITEM
							FROM
								%table:DA1% DA1
							WHERE
								DA1_FILIAL = %exp:aFilCop[nT][1]%
								AND DA1_CODTAB = %exp:cCodDA0%
								AND DA1.%notDel%
							EndSql

							cItem := (cAliasITE)->DA1_ITEM

							(cAliasITE)->(DbCloseArea())

							//Geração do proximo registro
							While !(cAliasDA1)->(Eof())

								DA1->(DbgoTo((cAliasDA1)->RECNUM))

								aReg := {}

								For nA:=1 To Len(aStruct)

									aAdd(aReg, { aStruct[nA][1], DA1->&( aStruct[nA][1] ) } )

								Next nA

								nB := 0

								Reclock("DA1",.T.)

								For nB:=1 To Len(aReg)

									If Alltrim(aReg[nB][1]) == "DA1_XTABSQ"
										DA1->DA1_XTABSQ := cTabProc
										Loop
									EndIf

									If Alltrim(aReg[nB][1]) == "DA1_DATVIG"
										DA1->DA1_DATVIG := dDataBase
										Loop
									EndIf

									If Alltrim(aReg[nB][1]) == "DA1_ITEM"
										DA1->DA1_ITEM := Soma1(cItem)
										Loop
									EndIf

									DA1->&( aReg[nB][1] ) := aReg[nB][2]

								Next nB

								DA1->(MsUnlock())

								Reclock("DA1",.F.)
									DA1->DA1_XLETRA 	:= SZ3->Z3_LETRA
									DA1->DA1_XCDTAB 	:= SZ3->Z3_CODTAB
									DA1->DA1_XPRCBR 	:= SZ3->Z3_PRCBRT
									DA1->DA1_XPRCLI 	:= SZ3->Z3_PRCVEN
									DA1->DA1_XPRCRE 	:= SZ3->Z3_PRCREP
									DA1->DA1_XDESCV 	:= SZ3->Z3_DESCONT
									DA1->DA1_XMARGEM 	:= SZ3->Z3_MARGEM
									DA1->DA1_XFATOR 	:= ZZH->ZZH_INDICE
									DA1->DA1_PRCVEN 	:= SZ3->Z3_PRCVEN
								DA1->(MsUnlock())

								//Deleta Os registros
								nY := 0
								For nY:=1 To Len(aTabDel)
									DA1->(DbGoTo(aTabDel[nY]))
									Reclock("DA1",.F.)
										DA1->(DbDelete())
									DA1->(MsUnlock())
								Next nY

								(cAliasDA1)->(DbSkip())
							EndDo

							(cAliasDA1)->(DbCloseArea())

						EndIf

					Else

						RecLock("DA1",.T.)

						DA1->DA1_FILIAL 	:= aFilCop[nT][1]
						DA1->DA1_ITEM 		:= Soma1(ProxItem(cCodDA0))
						DA1->DA1_CODTAB 	:= cCodDA0
						DA1->DA1_CODPRO 	:= SZ3->Z3_COD
						DA1->DA1_PRCVEN 	:= SZ3->Z3_PRCVEN
						DA1->DA1_ATIVO  	:= "1"
						DA1->DA1_TPOPER 	:= "4"
						DA1->DA1_QTDLOT 	:= 999999.99
						DA1->DA1_INDLOT 	:= "000000000999999.99"
						DA1->DA1_MOEDA		:= 1
						DA1->DA1_DATVIG 	:= dDataBase
						DA1->DA1_XLETRA 	:= SZ3->Z3_LETRA
						DA1->DA1_XCDTAB 	:= SZ3->Z3_CODTAB
						DA1->DA1_XTABSQ 	:= "1"
						DA1->DA1_XPRCBR 	:= SZ3->Z3_PRCBRT
						DA1->DA1_XPRCLI 	:= SZ3->Z3_PRCVEN
						DA1->DA1_XPRCRE 	:= SZ3->Z3_PRCREP
						DA1->DA1_XDESCV 	:= SZ3->Z3_DESCONT
						DA1->DA1_XMARGEM 	:= SZ3->Z3_MARGEM
						DA1->DA1_XFATOR 	:= ZZH->ZZH_INDICE

						DA1->(MsUnLock())

					EndIf

					SZ3->(DbSkip())

				EndDo

			EndIf

		EndIf

	Next nT

Return()