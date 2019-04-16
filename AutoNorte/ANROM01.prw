#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TOTVS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} ANROM01
Tela de Romaneio
@author felipe.caiado
@since 11/03/2019
/*/
//-------------------------------------------------------------------
User Function ANROM01()

	Local oBrowse

	//Criação do objeoto Browse
	oBrowse := FWMBrowse():New()

	//Seta o Alias Browse
	oBrowse:SetAlias('SZC')

	//Seta a descrição do Browse
	oBrowse:SetDescription('Romaneio')

	//Adicao de legendas
	oBrowse:AddLegend( "ZC_STATUS == '1'", "GREEN"	, "Conferencia Aberta")
	oBrowse:AddLegend( "ZC_STATUS == '2'", "YELLOW"	, "Conferencia em Andamento")
	oBrowse:AddLegend( "ZC_STATUS == '3'", "BLUE"	, "Conferencia Finalizada")
	oBrowse:AddLegend( "ZC_STATUS == '4'", "RED"	, "Conferencia Finalizada com divergência")

	//Grafico
	oBrowse:SetAttach(.T.)

	//Ativa o Browse
	oBrowse:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Tela de Romaneio - Menu Funcional
@author felipe.caiado
@since 11/03/2019
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'  			ACTION 'PesqBrw'        	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 			ACTION 'VIEWDEF.ANROM01' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    			ACTION 'VIEWDEF.ANROM01' 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    			ACTION 'VIEWDEF.ANROM01' 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    			ACTION 'VIEWDEF.ANROM01' 	OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Consultar Paletes'    ACTION 'U_AN_CONFDG(SZC->ZC_DOC)' 		OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   			ACTION 'VIEWDEF.ANROM01' 	OPERATION 8 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Tela de Romaneio - Modelo de Dados
@author felipe.caiado
@since 11/03/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruSZC := FWFormStruct( 1, 'SZC', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruSZA := FWFormStruct( 1, 'SZA', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruSZD := FWFormStruct( 1, 'SZD', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruSD1 := FWFormStruct( 1, 'SD1', {|cCampo| Alltrim(cCampo) $ 'D1_9999'},/*lViewUsado*/ )
	Local oStruRES := FWFormStruct( 1, 'ZZZ', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	//Estrutura Tabela SD1
	oStruSD1:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Item') , ; 			// [02] C ToolTip do campo
	'D1_ITEM' , ;               // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	004 , ;                      // [05] N Tamanho do campo
	0 , ;                       // [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;  		// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruSD1:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('D1_COD') , ; 			// [02] C ToolTip do campo
	'D1_COD' , ;               // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	15 , ;                      // [05] N Tamanho do campo
	0 , ;                       // [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;  		// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruSD1:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('B1_DESC') , ; 			// [02] C ToolTip do campo
	'B1_DESC' , ;               // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	30 , ;                      // [05] N Tamanho do campo
	0 , ;                       // [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	{|| Iif(INCLUI,"",Posicione(("SB1"),1,xFilial("SB1")+SD1->D1_COD,"B1_DESC"))} , ;  					// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruSD1:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('D1_QUANT') , ; 			// [02] C ToolTip do campo
	'D1_QUANT' , ;               // [03] C identificador (ID) do Field
	'N' , ;                     // [04] C Tipo do campo
	TamSX3("D1_QUANT")[1], ;                      // [05] N Tamanho do campo
	TamSX3("D1_QUANT")[2] , ;                       // [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;  					// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruSD1:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Zona') , ; 			// [02] C ToolTip do campo
	'B5_CODZON' , ;               // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	TamSX3("B5_CODZON")[1], ;                      // [05] N Tamanho do campo
	TamSX3("B5_CODZON")[2] , ;                       // [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	{|| Iif(INCLUI,"",Posicione(("SB5"),1,xFilial("SB5")+SD1->D1_COD,"B5_CODZON"))} , ;  					// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	//Estrutura Tabela Resumo
	oStruRES:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Item') , ; 			// [02] C ToolTip do campo
	'D1_ITEM' , ;               // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	0004 , ;                      // [05] N Tamanho do campo
	0 , ;                       // [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;  		// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruRES:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Codigo') , ; 			// [02] C ToolTip do campo
	'B1_COD' , ;               // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	0015 , ;                      // [05] N Tamanho do campo
	0 , ;                       // [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;  		// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruRES:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Descricao') , ; 			// [02] C ToolTip do campo
	'B1_DESC' , ;               // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	0030 , ;                      // [05] N Tamanho do campo
	0 , ;                       // [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;  		// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruRES:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Quantidade') , ; 			// [02] C ToolTip do campo
	'D1_QUANT' , ;               // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	TamSX3("D1_QUANT")[1] , ;   // [05] N Tamanho do campo
	TamSX3("D1_QUANT")[2] , ;   // [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;  		// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruSD1:SetProperty("*",MODEL_FIELD_VALID,{|| .T.})
	oStruSD1:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('ANROM01M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'SZCMASTER', /*cOwner*/, oStruSZC, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona ao modelo uma estrutura de Grid
	oModel:AddGrid( 'SZADETAIL', 'SZCMASTER', oStruSZA, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  )
	oModel:AddGrid( 'SZDDETAIL', 'SZADETAIL', oStruSZD, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  )
	oModel:AddGrid( 'SD1DETAIL', 'SZDDETAIL', oStruSD1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  )
//	oModel:AddGrid( 'RESDETAIL', 'SD1DETAIL', oStruRES, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'SZADETAIL', { { 'ZA_FILIAL', 'xFilial( "SZA" )' }, { 'ZA_ROMANEI', 'ZC_DOC' } }, SZA->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'SZDDETAIL', { { 'ZD_FILIAL', 'xFilial( "SZD" )' }, { 'ZD_ROMANEI', 'ZC_DOC' }, { 'ZD_CONHEC', 'ZA_DOC' }, { 'ZD_ITCONH', 'ZA_ITEM' } }, SZD->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'SD1DETAIL', { { 'D1_FILIAL', 'xFilial( "SZC" )' }, { 'D1_DOC', 'ZD_NF' }, { 'D1_SERIE', 'ZD_SERIE' }, { 'D1_FORNECE', 'ZC_CODFORN' }, { 'D1_LOJA', 'ZC_LOJAFOR' }}, SD1->( IndexKey( 1 ) ) )

	//Chave Primaria
	oModel:SetPrimaryKey( {"ZC_FILIAL", "ZC_COD"})

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Romaneio' )

	oModel:GetModel( 'SD1DETAIL' ):SetOnlyView( .T. )
	oModel:GetModel( 'SD1DETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'SD1DETAIL' ):SetOptional( .T. )

	//oModel:GetModel( 'RESDETAIL' ):SetOnlyView( .T. )
	//oModel:GetModel( 'RESDETAIL' ):SetOnlyQuery( .T. )
//	oModel:GetModel( 'RESDETAIL' ):SetOptional( .T. )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'SZCMASTER' ):SetDescription( 'Romaneio' )
	oModel:GetModel( 'SZADETAIL' ):SetDescription( 'Romaneio' )
	oModel:GetModel( 'SZDDETAIL' ):SetDescription( 'Notas' )
	oModel:GetModel( 'SD1DETAIL' ):SetDescription( 'Itens' )
//	oModel:GetModel( 'RESDETAIL' ):SetDescription( 'Resultado' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela de Romaneio - Interface com usuário
@author felipe.caiado
@since 11/03/2019
@version undefined

@type function
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'ANROM01' )
	// Cria a estrutura a ser usada na View
	Local oStruSZC := FWFormStruct( 2, 'SZC', /*bAvalCampo*/)
	Local oStruSZA := FWFormStruct( 2, 'SZA', /*bAvalCampo*/)
	Local oStruSZD := FWFormStruct( 2, 'SZD', /*bAvalCampo*/)
	Local oStruSD1 := FWFormStruct( 2, 'SD1', {|cCampo| Alltrim(cCampo) $ 'D1_9999'})
	Local oStruRES := FWFormStruct( 2, 'ZZZ', /*bAvalCampo*/)
	Local oView
	Local cOrdem    := '00'

	//Estrutura Tabela SD1
	oStruSD1:AddField( ;            		// Ord. Tipo Desc.
	'D1_ITEM'                   	, ;   	// [01]  C   Nome do Campo
	"00"                         	, ;     // [02]  C   Ordem
	AllTrim( 'Item'    )         , ;     // [03]  C   Titulo do campo
	AllTrim( 'Item' )       , ;     // [04]  C   Descricao do campo
	{ 'Item' } 		, ;     // [05]  A   Array com Help
	'C'                             , ;     // [06]  C   Tipo do campo
	'@!'                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruSD1:AddField( ;            		// Ord. Tipo Desc.
	'D1_COD'                   	, ;   	// [01]  C   Nome do Campo
	cOrdem                         	, ;     // [02]  C   Ordem
	AllTrim( 'Produto'    )         , ;     // [03]  C   Titulo do campo
	AllTrim( 'Produto' )       , ;     // [04]  C   Descricao do campo
	{ 'Produto' } 		, ;     // [05]  A   Array com Help
	'C'                             , ;     // [06]  C   Tipo do campo
	'@!'                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruSD1:AddField( ;            		// Ord. Tipo Desc.
	'B1_DESC'                   	, ;   	// [01]  C   Nome do Campo
	cOrdem                         	, ;     // [02]  C   Ordem
	AllTrim( 'Descricao'    )         , ;     // [03]  C   Titulo do campo
	AllTrim( 'Descricao' )       , ;     // [04]  C   Descricao do campo
	{ 'Descricao' } 		, ;     // [05]  A   Array com Help
	'C'                             , ;     // [06]  C   Tipo do campo
	'@!'                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruSD1:AddField( ;            		// Ord. Tipo Desc.
	'D1_QUANT'                   	, ;   	// [01]  C   Nome do Campo
	cOrdem                         	, ;     // [02]  C   Ordem
	AllTrim( 'Quantidade'    )         , ;     // [03]  C   Titulo do campo
	AllTrim( 'Quantidade' )       , ;     // [04]  C   Descricao do campo
	{ 'Quantidade' } 		, ;     // [05]  A   Array com Help
	'C'                             , ;     // [06]  C   Tipo do campo
	PesqPict( "SD1", "D1_QUANT" )                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo


	cOrdem := Soma1( cOrdem )
	oStruSD1:AddField( ;            		// Ord. Tipo Desc.
	'B5_CODZON'                   	, ;   	// [01]  C   Nome do Campo
	cOrdem                         	, ;     // [02]  C   Ordem
	AllTrim( 'Zona'    )         , ;     // [03]  C   Titulo do campo
	AllTrim( 'Zona' )       , ;     // [04]  C   Descricao do campo
	{ 'Zona' } 		, ;     // [05]  A   Array com Help
	'C'                             , ;     // [06]  C   Tipo do campo
	PesqPict( "SB5", "B5_CODZON" )                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo

	//Estrutura Tabela Resumo
	cOrdem := "00"

	cOrdem := Soma1( cOrdem )
	oStruRES:AddField( ;            		// Ord. Tipo Desc.
	'D1_ITEM'                   	, ;   	// [01]  C   Nome do Campo
	cOrdem                         	, ;     // [02]  C   Ordem
	AllTrim( 'Item'    )         , ;     // [03]  C   Titulo do campo
	AllTrim( 'Item' )       , ;     // [04]  C   Descricao do campo
	{ 'Item' } 		, ;     // [05]  A   Array com Help
	'C'                             , ;     // [06]  C   Tipo do campo
	'@!'                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruRES:AddField( ;            		// Ord. Tipo Desc.
	'B1_COD'                   	, ;   	// [01]  C   Nome do Campo
	cOrdem                         	, ;     // [02]  C   Ordem
	AllTrim( 'Codigo'    )         , ;     // [03]  C   Titulo do campo
	AllTrim( 'Codigo' )       , ;     // [04]  C   Descricao do campo
	{ 'Codigo' } 		, ;     // [05]  A   Array com Help
	'C'                             , ;     // [06]  C   Tipo do campo
	'@!'                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruRES:AddField( ;            		// Ord. Tipo Desc.
	'B1_DESC'                   	, ;   	// [01]  C   Nome do Campo
	cOrdem                         	, ;     // [02]  C   Ordem
	AllTrim( 'Descricao'    )         , ;     // [03]  C   Titulo do campo
	AllTrim( 'Descricao' )       , ;     // [04]  C   Descricao do campo
	{ 'Descricao' } 		, ;     // [05]  A   Array com Help
	'C'                             , ;     // [06]  C   Tipo do campo
	'@!'                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruRES:AddField( ;            		// Ord. Tipo Desc.
	'D1_QUANT'                   	, ;   	// [01]  C   Nome do Campo
	cOrdem                         	, ;     // [02]  C   Ordem
	AllTrim( 'Quantidade'    )         , ;     // [03]  C   Titulo do campo
	AllTrim( 'Quantidade' )       , ;     // [04]  C   Descricao do campo
	{ 'Quantidade' } 		, ;     // [05]  A   Array com Help
	'N'                             , ;     // [06]  C   Tipo do campo
	PesqPict( "SD1", "D1_QUANT" )                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_SZC', oStruSZC, 'SZCMASTER' )

	//Adiciona no nosso View um controle do tipo Grid(antiga GetDados)
	oView:AddGrid( 'VIEW_SZA', oStruSZA, 'SZADETAIL' )
	oView:AddGrid( 'VIEW_SZD', oStruSZD, 'SZDDETAIL' )
	oView:AddGrid( 'VIEW_SD1', oStruSD1, 'SD1DETAIL' )
//	oView:AddGrid( 'VIEW_RES', oStruRES, 'RESDETAIL' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR' , 30 )
	oView:CreateHorizontalBox( 'INFERIOR' , 70 )

	// Cria Folder na view
	oView:CreateFolder( 'PASTAS01','INFERIOR' )

	// Cria pastas nas folders
	oView:AddSheet( 'PASTAS01', 'ABA01', 'Romaneio x Notas Fiscais' ) //Aba01

	oView:CreateVerticalBox( 'P01ABA01ESQ', 40,,, 'PASTAS01', 'ABA01')
	oView:CreateVerticalBox( 'P01ABA01DIR', 60,,, 'PASTAS01', 'ABA01')

	oView:CreateHorizontalBox( 'P01ABA01DIR01', 50,'P01ABA01DIR',, 'PASTAS01', 'ABA01')
	oView:CreateHorizontalBox( 'P01ABA01DIR02', 50,'P01ABA01DIR',, 'PASTAS01', 'ABA01')

//	oView:AddSheet( 'PASTAS01', 'ABA02', 'Resumo por produto' ) //Aba02
//
//	oView:CreateHorizontalBox( 'P01ABA02', 100,'',, 'PASTAS01', 'ABA02')

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_SZC', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_SZA', 'P01ABA01ESQ' )
	oView:SetOwnerView( 'VIEW_SZD', 'P01ABA01DIR01' )
	oView:SetOwnerView( 'VIEW_SD1', 'P01ABA01DIR02' )
//	oView:SetOwnerView( 'VIEW_RES', 'P01ABA02' )

	//Campo Incremental
	oView:AddIncrementField("SZADETAIL","ZA_ITEM")
	oView:AddIncrementField("SZDDETAIL","ZD_ITEM")

	oView:SetOnlyView( "VIEW_SD1")
	//oView:SetOnlyView( "VIEW_RES")
	//oView:SetVldFolder({|cFolderID, nOldSheet, nSelSheet| CarregaRes(nSelSheet)})

	//Indica se a janela deve ser fechada ao final da operação. Se ele retornar .T. (verdadeiro) fecha a janela
	oView:bCloseOnOK := {|| .T.}

Return oView

/*/{Protheus.doc} CarregaRes
Carga o resumo por produto
@author felipe.caiado
@since 11/03/2019
@version 1.0
@type function
/*/
Static Function CarregaRes(nSelSheet)

	Local oModel    := FwModelActivate()
	Local oObjSZC   := oModel:GetModel("SZCDETAIL")
	Local oObjRES   := oModel:GetModel("RESDETAIL")
	Local oObjSZA   := oModel:GetModel("SZADETAIL")
	Local oObjSZD   := oModel:GetModel("SZDDETAIL")
	Local nCount	:= 0
	Local nX		:= 0
	Local nY		:= 0
	Local nLinhaRES  	:= 1

	If nSelSheet == 2

		If !Empty(oObjRES:GetValue("D1_ITEM"))

			For nCount := 1 to oObjRES:Length()
				oObjRES:GoLine(nCount)

				//-- Deleta a parcela do cronograma
				If !oObjRES:IsDeleted()
					oObjRES:SetNoDeleteLine(.F.)
		   			oObjRES:DeleteLine()
					oObjRES:SetNoDeleteLine(.T.)
				EndIf
			Next nCount

		EndIf

		If !oObjRES:CanUpdateLine()
			oObjRES:SetNoUpdateLine(.F.)
		EndIf

		cQNF := ""
		For nX := 1 to oObjSZA:Length()
			oObjSZA:GoLine(nX)

			If !oObjSZA:IsDeleted() //Deletado

				For nY := 1 to oObjSZD:Length()
					oObjSZD:GoLine(nY)

					If !oObjSZD:IsDeleted() //Deletado

						If Trim(TcGetDb()) = 'ORACLE'
							cQNF += "D1_DOC || D1_SERIE = '" + oObjSZD:GetValue("ZD_NF") + oObjSZD:GetValue("ZD_SERIE") + "'"
						Else
							cQNF += "D1_DOC + D1_SERIE = '" + oObjSZD:GetValue("ZD_NF") + oObjSZD:GetValue("ZD_SERIE") + "'"
						Endif
						If nY < oObjSZD:Length()
							cQNF += " OR "
						Else
							cQNF += ")"
						Endif
					EndIF
				Next nY

			EndIf

		Next nX

		cAliasSum := GetNextAlias()

		cQuery := "SELECT D1_COD, D1_LOCAL, D1_UM, SUM(D1_QUANT) D1_QUANT"
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
		cQuery += " WHERE D1_FILIAL = '" + xFilial("SD1") + "'"
		cQuery += " AND D1_FORNECE = '" + FwFldGet("ZC_CODFORN") + "'"
		cQuery += " AND D1_LOJA = '" +  FwFldGet("ZC_LOJAFOR") + "'"
		cQuery += " AND ("
		cQuery += cQNF
		cQuery += " AND SD1.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY D1_COD, D1_LOCAL, D1_UM"
		cQuery += " ORDER BY D1_COD, D1_LOCAL, D1_UM"
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSum,.T.,.T.)

		cItem := "0000"

		While !(cAliasSum)->(Eof())

			//-- Caso a linha nao esteja em branco, adiciona uma linha
			If !Empty(oObjRES:GetValue("D1_ITEM"))
				oObjRES:SetNoInsertLine(.F.)
				nNewLine := oObjRES:AddLine()
				oObjRES:GoLine( nNewLine )
				oObjRES:SetNoInsertLine(.T.)
			EndIf

			lUpdCNF := oObjRES:CanUpdateLine()

			If !lUpdCNF
				oObjRES:SetNoUpdateLine(.F.)
			EndIf

			oObjRES:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

//			If nLinhaRES > 1
//				If oObjRES:AddLine() <> nLinhaRES
//					Help( ,, 'HELP',, 'Nao incluiu linha SD1' + CRLF + oModel:getErrorMessage()[6], 1, 0)
//					Loop
//				EndIf
//			EndIf

			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+(cAliasSum)->D1_COD))

			cItem := Soma1(cItem)

			oObjRES:SetValue( 'D1_ITEM',cItem )
			oObjRES:SetValue( 'B1_COD',(cAliasSum)->D1_COD )
			oObjRES:SetValue( 'B1_DESC',Substr(SB1->B1_DESC,1,30) )
			oObjRES:SetValue( 'D1_QUANT',(cAliasSum)->D1_QUANT )

			nLinhaRES++

			(cAliasSum)->(DbSkip())
		EndDo

		oObjRES:SetNoUpdateLine(!lUpdCNF)

		//-- Tratamento para remover linhas deletadas da tela
		oObjRES:SetNoDeleteLine(.F.)
		While oObjRES:IsDeleted(oObjRES:Length())
			oObjRES:GoLine(oObjRES:Length())
			oObjRES:DeleteLine(.T.,.T.)
		End
		oObjRES:SetNoDeleteLine(.T.)

	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDOCCH
Validação do Campo Romaneio
@author felipe.caiado
@since 11/03/2019
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
User Function VldDOCCH

	Local _aArea 	:= GetArea()
	Local lRetorno 	:= .T.
	Local oModel    := FwModelActivate()
	Local oObjSZA   := oModel:GetModel("SZADETAIL")
	Local _cCodForn := FwFldGet("ZC_CODFORN")
	Local _cLojForn := FwFldGet("ZC_LOJAFOR")
	Local _cConhec	:= Strzero(Val(FwFldGet("ZA_DOC")),TAMSX3("ZA_DOC")[1])
	Local _cRomane	:= FwFldGet("ZC_DOC")

	FwFldPut("ZA_DOC",_cConhec)

	If Empty(_cCodForn) .or. Empty(_cLojForn)
		Help( NIL, NIL, "FORNINF", NIL, "Fornecedor não informado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informar o fornecedor no cabeçalho da tela"})
		lRetorno := .F.
	Endif

	If lRetorno
		If !oModel:GetOperation() == 3
			_cConhAnt := oObjSZA:GetValue("ZA_DOC")
			If !Empty(_cConhAnt)
				dbSelectArea("SZA")
				SZA->(dbSetOrder(2))
				If SZA->(DbSeek(xFilial()+_cConhAnt))
					Help( NIL, NIL, "NALTCONH", NIL, "Conhecimento não pode ser alterado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para alterar deverá excluir a linha e incluir uma nova linha"})
					lRetorno := .F.
				Endif
			Endif
		Endif
	Endif

	If lRetorno
		dbSelectArea("SZA")
		SZA->(dbSetOrder(2))
		If SZA->(DbSeek(xFilial()+_cConhec))
			If SZA->ZA_ROMANEI <> _cRomane
				Help( NIL, NIL, "CONHJEXI", NIL, "Conhecimento já informado no Romaneio: " + SZA->ZA_ROMANEI, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Conhecimento já cadastrado"})
				lRetorno := .F.
			Endif
		Endif
	Endif

	If lRetorno

		nLinha := oObjSZA:nLine

		For nT := 1 To oObjSZA:Length()

			oObjSZA:GoLine(nT)

			If !oObjSZA:IsDeleted() //Deletado

				If nLinha <> nT

					If oObjSZA:GetValue("ZA_DOC") == _cConhec
						Help( NIL, NIL, "CONHJEXI", NIL, "Conhecimento já informado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Conhecimento já cadastrado"})
						lRetorno := .F.
					EndIf

				EndIf

			EndIf

		Next nT

	Endif

	RestArea(_aArea)
Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} VldROM
Validação do campo de Nota Fiscal
@author felipe.caiado
@since 11/03/2019
@version 1.0
@param _cParam, , descricao
@type function
/*/
//-------------------------------------------------------------------
User Function VldROM(_cParam)

	Local _aArea := GetArea()
	Local _cCodForn := FwFldGet("ZC_CODFORN")
	Local _cLojForn := FwFldGet("ZC_LOJAFOR")
	Local lRetorno:= .T.
	Local oModel    := FwModelActivate()
	Local oObjSZD   := oModel:GetModel("SZDDETAIL")
	Local cNF		:= IIF(_cParam=="1", StrZero(Val(oObjSZD:GetValue("ZD_NF")),TAMSX3("ZD_NF")[1]), oObjSZD:GetValue("ZD_NF"))
	Local cSerie2 	:= IIF(_cParam=="2", oObjSZD:GetValue("ZD_SERIE"), oObjSZD:GetValue("ZD_SERIE"))

	If _cParam=="1"
		FwFldPut("ZD_NF",cNF)
	Endif

	If !Empty(_cCodForn) .and. !Empty(_cLojForn)
		If !Empty(cSerie2) .and. !Empty(cNF)
			lRetorno := VlExisNF(cNF, cSerie2, _cCodForn, _cLojForn)
			If lRetorno
				dbSelectArea("SZD")
				SZD->(dbSetOrder(2))
				If SZD->(MsSeek(xFilial("SZD")+cNF+cSerie2+_cCodForn+_cLojForn))
					Help(" ",1,"EXISTNF")
					lRetorno := .F.
				Else
					//Carrega a SD1
					CarregaSD1(cNF, cSerie2, _cCodForn, _cLojForn)
				EndIf
			Endif
		Endif
	Endif
	RestArea(_aArea)

Return(lRetorno)

Static Function CarregaSD1(cNF, cSerie2, _cCodForn, _cLojForn)

	Local nY			:= 0
	Local oModel     	:= FWModelActive()
	Local oModelSD1  	:= oModel:GetModel( 'SD1DETAIL' )
	Local nLinhaSD1  	:= 1

	If oModelSD1:Length() > 1
		ApMsgInfo("Ja existe registros no módulo, preenchimento não executado")
		Return()
	EndIf

	DbSelectArea("SD1")
	SD1->(DbSetORder(1))
	If SD1->(DbSeek(xFilial("SD1")+cNF+cSerie2+_cCodForn+_cLojForn))
		While !SD1->(Eof()) .And. xFilial("SD1")+cNF+cSerie2+_cCodForn+_cLojForn == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

			oModelSD1:SetNoInsertLine(.F.)

			If nLinhaSD1 > 1
				If oModelSD1:AddLine() <> nLinhaSD1
					Help( ,, 'HELP',, 'Nao incluiu linha SD1' + CRLF + oModel:getErrorMessage()[6], 1, 0)
					Loop
				EndIf
			EndIf

			oModelSD1:SetNoInsertLine(.T.)

			lUpdCNF := oModelSD1:CanUpdateLine()

			If !lUpdCNF
				oModelSD1:SetNoUpdateLine(.F.)
			EndIf

			oModelSD1:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))

			DbSelectArea("SB5")
			SB5->(DbSetOrder(1))
			SB5->(DbSeek(xFilial("SB5")+SD1->D1_COD))

			oModelSD1:SetValue( 'D1_ITEM',SD1->D1_ITEM )
			oModelSD1:SetValue( 'D1_COD',SD1->D1_COD )
			oModelSD1:SetValue( 'B1_DESC',Substr(SB1->B1_DESC,1,30) )
			oModelSD1:SetValue( 'D1_QUANT',SD1->D1_QUANT )
			oModelSD1:SetValue( 'B5_CODZON',SB5->B5_CODZON )

			oModelSD1:SetNoUpdateLine(!lUpdCNF)

			nLinhaSD1++

			SD1->(DbSkip())
		EndDo
	EndIf

Return()

/*/{Protheus.doc} VlExisNF
Valida a NF
@author felipe.caiado
@since 11/03/2019
@version 1.0
@type function
/*/
Static Function VlExisNF(cNF, cSerie2, _cCodForn, _cLojForn)

	Local _lRet := .T.
	Local _aArea := GetArea()
	dbSelectArea("SF1")
	dbSetOrder(1)
	If !MsSeek(xFilial("SF1")+cNF+cSerie2+_cCodForn+_cLojForn)
		Help( NIL, NIL, "NFNEXIST", NIL, "Documento: " + cNF + "-" + cSerie2 + " não existe!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verificar se a NF informada foi digitada"})
		_lRet := .F.
	Else
		If !Empty(SF1->F1_STATUS)
			Help( NIL, NIL, "NFJCLASS", NIL, "Documento: " + cNF + "-" + cSerie2 + " já foi classificada", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Necessário estornar a classificação da NF"})
			_lRet := .F.
		Endif
	EndIf
	RestArea(_aArea)

Return(_lRet)

