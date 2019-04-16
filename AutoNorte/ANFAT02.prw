#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TOTVS.CH'

#DEFINE SM0_FILIAL	02
#DEFINE SM0_CNPJ	18

//-------------------------------------------------------------------
/*/{Protheus.doc} ANFAT02
Solicitação de Transferência
@author felipe.caiado
@since 28/03/2019
/*/
//-------------------------------------------------------------------
User Function ANFAT02()

	Local oBrowse

	//Criação do objeoto Browse
	oBrowse := FWMBrowse():New()

	//Seta o Alias Browse
	oBrowse:SetAlias('ZZU')

	//Seta a descrição do Browse
	oBrowse:SetDescription('Solicitação de Transferência')

	//Adicao de legendas
	oBrowse:AddLegend( "ZZU_STATUS =='1'", "GREEN"	, "Aguardando aprovação")
	oBrowse:AddLegend( "ZZU_STATUS =='2'", "RED"	, "Aprovada")

	//Ativa o Browse
	oBrowse:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Solicitação de Transferência - Menu Funcional
@author felipe.caiado
@since 28/03/2019
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'        	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.ANFAT02' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.ANFAT02' 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.ANFAT02' 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.ANFAT02' 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Aprovar'    ACTION 'U_ANFAT02A()'		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.ANFAT02' 	OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.ANFAT02' 	OPERATION 9 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Solicitação de Transferência - Modelo de Dados
@author felipe.caiado
@since 28/03/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZZU := FWFormStruct( 1, 'ZZU', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruZZV := FWFormStruct( 1, 'ZZV', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('ANFAT02M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZZUMASTER', /*cOwner*/, oStruZZU, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona ao modelo uma estrutura de Grid
	oModel:AddGrid("ZZVDETAIL", "ZZUMASTER"/*cOwner*/, oStruZZV , ,/*bLinePost*/,/*bPre*/,/*bPost*/,/*Carga*/)

	// Relacionamento entre os modelos
	oModel:SetRelation("ZZVDETAIL",{{"ZZV_FILIAL",'xFilial("ZZV")'},{"ZZV_CODIGO","ZZU_CODIGO"}},ZZV->(IndexKey()))

	//Chave Primaria
	oModel:SetPrimaryKey( {"ZZU_FILIAL", "ZZU_CODIGO"})

	//Seta a unique line
	oModel:GetModel( 'ZZVDETAIL' ):SetUniqueLine( { 'ZZV_ITEM' } )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Solicitação de Transferência' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZZUMASTER' ):SetDescription( 'Solicitação de Transferência' )
	oModel:GetModel( 'ZZVDETAIL' ):SetDescription( 'Itens da Transferência' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Solicitação de Transferência - Interface com usuário
@author felipe.caiado
@since 28/03/2019
@version undefined

@type function
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'ANFAT02' )
	// Cria a estrutura a ser usada na View
	Local oStruZZU := FWFormStruct( 2, 'ZZU', /*bAvalCampo*/)
	Local oStruZZV := FWFormStruct( 2, 'ZZV', /*bAvalCampo*/)
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZZU', oStruZZU, 'ZZUMASTER' )

	//Adiciona no nosso View um controle do tipo Grid
	oView:AddGrid( 'VIEW_ZZV', oStruZZV, 'ZZVDETAIL' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR' , 40 )
	oView:CreateHorizontalBox( 'INFERIOR' , 60 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZZU', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_ZZV', 'INFERIOR' )

	//Campos incrementais
	oView:AddIncrementField( 'VIEW_ZZV', 'ZZV_ITEM' )

	// Liga a identificacao do componente
	oView:EnableTitleView('VIEW_ZZV','Itens da Transferência')

	//Indica se a janela deve ser fechada ao final da operação. Se ele retornar .T. (verdadeiro) fecha a janela
	oView:bCloseOnOK := {|| .T.}

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ANFAT02A
Aprovação da Solicitação
@author felipe.caiado
@since 28/03/2019
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
User Function ANFAT02A()

	If ApMsgYesNo("Confirma a aprovação da solicitação da transferência?")
		FwMsgRun(Nil,{||AN001() },Nil,"Aguarde, Criando pedido de venda para faturamento...")
	EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN001
Gravação do Pedido de Venda
@author felipe.caiado
@since 28/03/2019
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Static Function AN001()

	Local oServer 		as object
	Local cRpcServer	as character
	Local nRPCPort 		as numeric
	Local cRPCEnv 		as character
	Local aCab			as array
	Local aItem			as array
	Local aItens		as array
	Local aSM0			as array
	Local nX			as numeric
	Local cCNPJDest		as character
	Local cItem			as character
	Local cTES			as character
	Local aRet			as array
	Local nPreco		as numeric

	cRpcServer		:= GetServerIp()
	nRPCPort 		:= Val(GetPvProfString("TCP", "Port", "\\undefined", GetAdv97()))
	cRPCEnv			:= Alltrim(Upper(GetEnvServer()))
	aCab			:= {}
	aItem			:= {}
	aItens			:= {}
	aSM0 			:= FWLoadSM0(.T.)
	nX				:= 0
	cCNPJDest		:= ""
	cItem			:= "00"
	nPreco 			:= 0

	If cFilAnt <> ZZU->ZZU_FILORI
		Help( ,, 'HELP',, 'Filial diferente', 1, 0)
		Return()
	EndIF

	//Pesquisa o CNPJ da filial de destino
	For nX:=1 To Len(aSM0)

		//Verifica se a filial é igual a da nota
		If Alltrim(aSM0[nX][SM0_FILIAL]) == Alltrim(ZZU->ZZU_FILDES)

			cCNPJDest := Alltrim(aSM0[nX][SM0_CNPJ])

		EndIf

	Next nX

	DbSelectArea("SA1")
	SA1->(DbSetOrder(3))//A1_FILIAL+A1_CGC
	If !SA1->(DbSeek(xFilial("SA1")+cCNPJDest))

		Help( ,, 'HELP',, 'Cliente não encontrado para inclusão do pedido de venda', 1, 0)
		Return()

	EndIf

	//Cabeçalho do pedido de venda
	aAdd(aCab, {"C5_FILIAL" , xFilial("SC5")   	, Nil})     // Filial do pedido
	aAdd(aCab, {"C5_TIPO"   , 'N'   			, Nil})     // Tipo do pedido
	aAdd(aCab, {"C5_CLIENTE", SA1->A1_COD    	, Nil})     // Cliente
	aAdd(aCab, {"C5_LOJA"   , SA1->A1_LOJA   	, Nil})     // Loja
	aAdd(aCab, {"C5_EMISSAO", dDataBase			, Nil})     // Data de Emissão
	aAdd(aCab, {"C5_CLIENT" , SA1->A1_COD    	, Nil})     // Código do cliente entrega
	aAdd(aCab, {"C5_LOJAENT", SA1->A1_LOJA   	, Nil})     // Loja do cliente entrega
	aAdd(aCab, {"C5_CONDPAG", "1"           	, Nil})     // Condição de Pagamento - a Vista
	aAdd(aCab, {"C5_TIPLIB" , "1"            	, Nil})     // Permitir liberar o pedido parcialmente
	aAdd(aCab, {"C5_NATUREZ", SA1->A1_NATUREZ	, Nil})     // Natureza do cliente

	DbSelectArea("ZZV")
	ZZV->(DbSetOrder(1))
	If ZZV->(DbSeek(xFilial("ZZV")+ZZU->ZZU_CODIGO))

		While !ZZV->(Eof()) .And. xFilial("ZZV")+ZZU->ZZU_CODIGO == ZZV->ZZV_FILIAL+ZZV->ZZV_CODIGO

			aItem := {}
			cItem := Soma1(cItem)

			//Posiciona no produto
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD
			SB1->(DbSeek(xFilial("SB1")+ZZV->ZZV_PRODUT))

			//Posiciona nA SB2
			DbSelectArea("SB2")
			SB2->(DbSetOrder(1))//B2_FILIAL+B2_COD+B2_LOCAL
			If SB2->(DbSeek(xFilial("SB2")+ZZV->ZZV_PRODUT+SB1->B1_LOCPAD))
				nPreco := SB2->B2_CM1
			Else
				nPreco := 0
			EndIf

			cTES := MaTesInt(2,"01",SA1->A1_COD,SA1->A1_LOJA,"C",ZZV->ZZV_PRODUT,)

			aAdd(aItem,{"C6_FILIAL" , xFilial("SC6")   					, Nil})	   //Filial
			aAdd(aItem,{"C6_ITEM"   , cItem			   					, Nil})    // Item do pedido
			aAdd(aItem,{"C6_PRODUTO", ZZV->ZZV_PRODUT					, Nil})    // Produto
			aAdd(aItem,{"C6_DESCRI" , SB1->B1_DESC	 					, Nil})    // Descricao
			aAdd(aItem,{"C6_UM"     , SB1->B1_UM     					, Nil})    // Unidade de medida do produto
			aAdd(aItem,{"C6_QTDVEN" , ZZV->ZZV_QUANT 					, Nil})    // Quantidade Vendida
			aAdd(aItem,{"C6_QTDLIB" , ZZV->ZZV_QUANT 					, Nil})    // Quantidade Liberada
			aAdd(aItem,{"C6_PRCVEN" , Round(nPreco,4) 					, Nil})    // Preço unitario
			aAdd(aItem,{"C6_VALOR"  , A410Arred(nPreco * ZZV->ZZV_QUANT,"C6_VALOR") 	, Nil})    // Valor total
			aAdd(aItem,{"C6_TES" 	, cTES			 					, Nil})    // TES
			aAdd(aItem,{"C6_LOCAL"  , SB1->B1_LOCPAD  					, Nil})    // Local padrão do produto (Armazem)
			aAdd(aItem,{"C6_ENTREG" , dDataBase		 					, Nil})    // Data da Entrega

			aAdd(aItens,aItem)

			ZZV->(DbSkip())

		EndDo

	EndIf

	cFunName := Alltrim(FunName())

	SetFunName("MATA410")

	//Insere as notas fiscais
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z| MATA410(x,y,z)},aCab,aItens,3)

	SetFunName(cFunName)

	If lMsErroAuto
		MostraErro()
	Else
		//Marca como aprovada a solicitação
		Reclock('ZZU',.F.)
		ZZU->ZZU_STATUS := '2'
		ZZU->(MsUnLock())
	EndIf


Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ANFAT02B
Criação da Pre nota
@author felipe.caiado
@since 13/03/2019
@version 1.0
@param aCab, array, Cabecalho do pedido
@param aDet, array, Item do pedido
@param cEmpDest, characters, Empresa
@param cFilDes, characters, Filial
@type function
/*/
//-------------------------------------------------------------------
User Function ANFAT02B(aCab, aItens, cEmpDest, cFilDes)

	Local lRet		as logical
	Local aRet		as array
	Local cRet		as character

	lRet 	:= .F.
	cRet 	:= ""

	//Conecta na filial de destino
	RpcSetEnv(cEmpDest, cFilDes)

	cFunName := Alltrim(FunName())

	SetFunName("MATA410")

	Conout("hhhhhhhhhhh")

	//Insere as notas fiscais
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z| MATA410(x,y,z)},aCab,aItens,3)

	Conout("yyyyyyyyyyyyy")

	SetFunName(cFunName)

	If lMsErroAuto
		cRet := MostraErro("\execauto\","MATA410.txt")
	Else
		lRet := .T.
	EndIf

	aRet := {lRet,cRet}

	//Desconecta da filial
	RpcClearEnv()

Return(aRet)