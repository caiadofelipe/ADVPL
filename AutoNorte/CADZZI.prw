#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TOTVS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CADZZI
Tabela de Letra
@author felipe.caiado
@since 27/03/2019
/*/
//-------------------------------------------------------------------
User Function CADZZI()

	Local oBrowse

	//Criação do objeoto Browse
	oBrowse := FWMBrowse():New()

	//Seta o Alias Browse
	oBrowse:SetAlias('ZZI')

	//Seta a descrição do Browse
	oBrowse:SetDescription('Tabela de Letra')

	//Adicao de legendas
	//oBrowse:AddLegend( "U01_STATUS =='A'", "GREEN"	, "Aluno Ativo")

	//Grafico
	oBrowse:SetAttach(.T.)

	//Ativa o Browse
	oBrowse:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Tabela de Letra - Menu Funcional
@author felipe.caiado
@since 27/03/2019
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'        	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.CADZZI' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.CADZZI' 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.CADZZI' 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.CADZZI' 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CADZZI' 	OPERATION 8 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Tabela de Letra - Modelo de Dados
@author felipe.caiado
@since 27/03/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZZI := FWFormStruct( 1, 'ZZI', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('CADZZIM', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'ZZIMASTER', /*cOwner*/, oStruZZI, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	//Chave Primaria
	oModel:SetPrimaryKey( {"ZZI_FILIAL", "ZZI_LETRA"})

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Tabela de Letra' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'ZZIMASTER' ):SetDescription( 'Tabela de Letra' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tabela de Letra - Interface com usuário
@author felipe.caiado
@since 27/03/2019
@version undefined

@type function
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'CADZZI' )
	// Cria a estrutura a ser usada na View
	Local oStruZZI := FWFormStruct( 2, 'ZZI', /*bAvalCampo*/)
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_ZZI', oStruZZI, 'ZZIMASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR' , 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_ZZI', 'SUPERIOR' )

	// Liga a identificacao do componente
	//oView:EnableTitleView('VIEW_U01','Alunos')

	//Indica se a janela deve ser fechada ao final da operação. Se ele retornar .T. (verdadeiro) fecha a janela
	oView:bCloseOnOK := {|| .T.}

Return oView