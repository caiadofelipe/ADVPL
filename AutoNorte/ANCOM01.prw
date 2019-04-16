#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWEditPanel.CH'

#DEFINE SM0_FILIAL	02

//-------------------------------------------------------------------
/*/{Protheus.doc} ANCOM01
Manutenção de Tabela de Preço
@author felipe.caiado
@since 13/03/2019
/*/
//-------------------------------------------------------------------
User Function ANCOM01A()

	Local aButtons 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	Private oCodigo
	Private cCodigo 	:= ""
	Private oDescri
	Private cDescri 	:= Space(40)
	Private lAltLetra	:= .F.
	Private lAltDesc	:= .F.
	Private	lCopPRep	:= .F.

	SetKEY( VK_F6, {|| 	FwMsgRun(Nil,{||AN007(lAltLetra,lAltDesc) },Nil,"Aguarde, Atualizando Preço...")} )
	SetKEY( VK_F7, {|| 	AN009(lAltLetra,lAltDesc)} )
	SetKEY( VK_F4, {|| 	lAltLetra := .F., lAltDesc := .F., AN004(lAltLetra, lAltDesc, "Atualização de Preço")} )
	SetKEY( K_CTRL_L, {|| lAltLetra := .T., lAltDesc := .F., AN004(lAltLetra, lAltDesc, "Atualização de Letra")} )
	SetKEY( K_CTRL_D, {|| lAltLetra := .F., lAltDesc := .T., AN004(lAltLetra, lAltDesc, "Atualização de Desconto")} )
	SetKEY( K_CTRL_P, {|| AN010()} )
	SetKEY( K_CTRL_R, {|| AN011()} )
	SetKEY( VK_F12, {|| FwMsgRun(Nil,{||AN002(oCodigo, oDescri) },Nil,"Aguarde, Executando Filtro...")} )

	FWExecView("Manutenção de Tabela de Preço","ANCOM01",MODEL_OPERATION_INSERT,,{|| .T.},,,aButtons	)

	SetKEY( VK_F6, nil )
	SetKEY( VK_F4, nil )
	SetKEY( VK_F7, NIL )
	SetKEY( K_CTRL_L, NIL )
	SetKEY( K_CTRL_D, NIL )
	SetKEY( K_CTRL_P, NIL )
	SetKEY( K_CTRL_R, NIL )
	SetKEY( VK_F12, nil )

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Manutenção de Tabela de Preço - Modelo de Dados
@author felipe.caiado
@since 13/03/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruFIL 	:= FWFormStruct( 1, 'ZZZ')
	Local oStruSB1 	:= FWFormStruct( 1, 'SB1', {|cCampo| Alltrim(cCampo) $ 'B1_COD/B1_DESC/B1_XLINHA'},/*lViewUsado*/ )
	Local oStruDA1	:= FWFormStruct( 1, 'DA1', {|cCampo| Alltrim(cCampo) $ 'DA1_XTABSQ/DA1_DATVIG/DA1_XPRCBR/DA1_XDESCV/DA1_XPRCLI/DA1_XLETRA/DA1_XPRCRE'},/*lViewUsado*/ )
	Local oStruALT	:= FWFormStruct( 1, 'ZZZ')
	Local oModel

	//Estrutura do Filtro
	oStruFIL:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Marca') , ; 		// [02] C ToolTip do campo
	'XX_MARCA' , ;              // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	TamSX3("B1_XMARCA")[1] , ;  // [05] N Tamanho do campo
	TamSX3("B1_XMARCA")[2] , ;  // [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruFIL:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Produto') , ; 		// [02] C ToolTip do campo
	'XX_PRODUT' , ;             // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	TamSX3("B1_COD")[1] , ;     // [05] N Tamanho do campo
	TamSX3("B1_COD")[2] , ;		// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruFIL:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Linha') , ; 		// [02] C ToolTip do campo
	'XX_LINHA' , ;             	// [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	TamSX3("B1_XLINHA")[1] , ;  // [05] N Tamanho do campo
	TamSX3("B1_XLINHA")[2] , ;	// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruFIL:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Curva') , ; 		// [02] C ToolTip do campo
	'XX_CURVA' , ;             	// [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	10 , ;  						// [05] N Tamanho do campo
	0 , ;						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruSB1:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Crv') , ; 		// [02] C ToolTip do campo
	'B1_CURVA' , ;             	// [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	1 , ;  						// [05] N Tamanho do campo
	0 , ;						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruDA1:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Filial') , ; 		// [02] C ToolTip do campo
	'DA1_FILIAL' , ;            // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	06 , ;  					// [05] N Tamanho do campo
	0 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruDA1:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Cst Aquis') , ; 	// [02] C ToolTip do campo
	'DA1_XCSTAQ' , ;            // [03] C identificador (ID) do Field
	'N' , ;                     // [04] C Tipo do campo
	8 , ;  						// [05] N Tamanho do campo
	2 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruDA1:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Documento') , ; 	// [02] C ToolTip do campo
	'DA1_XDOC' , ;            	// [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	9 , ;  						// [05] N Tamanho do campo
	0 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruALT:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Filial') , ; 		// [02] C ToolTip do campo
	'XX_FILIAL' , ;             // [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	06 , ;  					// [05] N Tamanho do campo
	0 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	{|| .F.} , ;                // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruALT:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Data') , ; 		// [02] C ToolTip do campo
	'XX_DATA' , ;            	// [03] C identificador (ID) do Field
	'D' , ;                     // [04] C Tipo do campo
	08 , ;  					// [05] N Tamanho do campo
	0 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                		// [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruALT:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Custo Aquis') , ; 	// [02] C ToolTip do campo
	'XX_CSTAQU' , ;            	// [03] C identificador (ID) do Field
	'N' , ;                     // [04] C Tipo do campo
	6 , ;  						// [05] N Tamanho do campo
	2 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	{|| .F.} , ;                // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruALT:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Preço Rep') , ; 	// [02] C ToolTip do campo
	'XX_PRCREP' , ;            	// [03] C identificador (ID) do Field
	'N' , ;                     // [04] C Tipo do campo
	6 , ;  						// [05] N Tamanho do campo
	2 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                		// [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruALT:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Letra') , ; 		// [02] C ToolTip do campo
	'XX_LETRA' , ;            	// [03] C identificador (ID) do Field
	'C' , ;                     // [04] C Tipo do campo
	01 , ;  					// [05] N Tamanho do campo
	0 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruALT:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Margem') , ; 		// [02] C ToolTip do campo
	'XX_MARGEM' , ;            	// [03] C identificador (ID) do Field
	'N' , ;                     // [04] C Tipo do campo
	8 , ;  						// [05] N Tamanho do campo
	2 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	{|| .F.} , ;                // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruALT:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Fator') , ; 		// [02] C ToolTip do campo
	'XX_FTPRC' , ;            	// [03] C identificador (ID) do Field
	'N' , ;                     // [04] C Tipo do campo
	5 , ;  						// [05] N Tamanho do campo
	3 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	{|| .F.} , ;                // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruALT:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Preço Bruto') , ; 	// [02] C ToolTip do campo
	'XX_PRCBRT' , ;            	// [03] C identificador (ID) do Field
	'N' , ;                     // [04] C Tipo do campo
	8 , ;  						// [05] N Tamanho do campo
	2 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	{|| .F.} , ;                // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruALT:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Desconto') , ; 	// [02] C ToolTip do campo
	'XX_DESCONT' , ;            // [03] C identificador (ID) do Field
	'N' , ;                     // [04] C Tipo do campo
	06 , ;  					// [05] N Tamanho do campo
	2 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	NIL , ;                     // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruALT:AddField( ;
	AllTrim('') , ; 			// [01] C Titulo do campo
	AllTrim('Preço Liq') , ; 	// [02] C ToolTip do campo
	'XX_PRCLIQ' , ;            	// [03] C identificador (ID) do Field
	'N' , ;                     // [04] C Tipo do campo
	8 , ;  						// [05] N Tamanho do campo
	2 , ;  						// [06] N Decimal do campo
	NIL , ;                     // [07] B Code-block de validação do campo
	{|| .F.} , ;                // [08] B Code-block de validação When do campo
	NIL , ;                     // [09] A Lista de valores permitido do campo
	NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
	NIL , ;						// [11] B Code-block de inicializacao do campo
	NIL , ;                     // [12] L Indica se trata de um campo chave
	NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )                       // [14] L Indica se o campo é virtual

	oStruFIL:SetProperty("*",MODEL_FIELD_WHEN,{|| .F.})
	oStruSB1:SetProperty("*",MODEL_FIELD_WHEN,{|| .F.})
	oStruSB1:SetProperty("*",MODEL_FIELD_VALID,{|| .T.})
	oStruDA1:SetProperty("*",MODEL_FIELD_WHEN,{|| .F.})
	oStruDA1:SetProperty("*",MODEL_FIELD_VALID,{|| .T.})
	oStruSB1:SetProperty("B1_DESC",MODEL_FIELD_TAMANHO ,20)

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('ANCOM01M', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'FILMASTER', /*cOwner*/, oStruFIL, /*bPreValidacao*/, /*bPosValidacao*/, )

	// Adiciona ao modelo uma estrutura de Grid
	oModel:AddGrid( 'SB1DETAIL', 'FILMASTER', oStruSB1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  )
	oModel:AddGrid( 'DA1DETAIL', 'FILMASTER', oStruDA1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  )
	oModel:AddGrid( 'ALTDETAIL', 'FILMASTER', oStruALT, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  )

	//Chave Primaria
	oModel:SetPrimaryKey( { , })

	//Gatilho para a data
	oStruALT:AddTrigger( ;
		"XX_DATA",	;
		"XX_CSTAQU",	;
		{ || .T. },	;
		{ || AN005(FwFldGet("XX_FILIAL"), cCodigo, 1)})

	oStruALT:AddTrigger( ;
		"XX_DATA",	;
		"XX_PRCREP",	;
		{ || .T. },	;
		{ || AN006(FwFldGet("XX_FILIAL"), cCodigo, "DA1_XPRCRE", "1")})

	oStruALT:AddTrigger( ;
		"XX_DATA",	;
		"XX_LETRA",	;
		{ || .T. },	;
		{ || AN006(FwFldGet("XX_FILIAL"), cCodigo, "DA1_XLETRA", "1")})

	oStruALT:AddTrigger( ;
		"XX_DATA",	;
		"XX_MARGEM",	;
		{ || .T. },	;
		{ || AN006(FwFldGet("XX_FILIAL"), cCodigo, "DA1_XMARGE", "1")})

	oStruALT:AddTrigger( ;
		"XX_DATA",	;
		"XX_FTPRC",	;
		{ || .T. },	;
		{ || AN006(FwFldGet("XX_FILIAL"), cCodigo, "DA1_XFATOR", "1")})

	oStruALT:AddTrigger( ;
		"XX_DATA",	;
		"XX_PRCBRT",	;
		{ || .T. },	;
		{ || AN006(FwFldGet("XX_FILIAL"), cCodigo, "DA1_XPRCBR", "1")})

	oStruALT:AddTrigger( ;
		"XX_DATA",	;
		"XX_DESCONT",	;
		{ || .T.},	;
		{ || AN006(FwFldGet("XX_FILIAL"), cCodigo, "DA1_XDESCV", "1")})

	oStruALT:AddTrigger( ;
		"XX_DATA",	;
		"XX_PRCLIQ",	;
		{ || .T. },	;
		{ || AN006(FwFldGet("XX_FILIAL"), cCodigo, "DA1_XPRCLI", "1")})

	oStruALT:AddTrigger( ;
		"XX_DESCONT",	;
		"XX_PRCLIQ",	;
		{ || .T. },	;
		{ || AN008()})

	oStruALT:AddTrigger( ;
		"XX_PRCREP",	;
		"XX_PRCLIQ",	;
		{ || .T. },	;
		{ || AN008()})

	oStruALT:AddTrigger( ;
		"XX_LETRA",	;
		"XX_PRCLIQ",	;
		{ || .T. },	;
		{ || AN008()})

	oStruALT:AddTrigger( ;
		"XX_LETRA",	;
		"XX_MARGEM",	;
		{ || .T. },	;
		{ || u_CalcPrcV(Upper(Alltrim(FwFldGet("XX_LETRA"))), cCodigo, FwFldGet("XX_FILIAL"), FwFldGet("XX_PRCREP"))[1]})

	oStruALT:AddTrigger( ;
		"XX_LETRA",	;
		"XX_FTPRC",	;
		{ || .T. },	;
		{ || u_CalcPrcV(FwFldGet("XX_LETRA"), cCodigo, FwFldGet("XX_FILIAL"), FwFldGet("XX_PRCREP"))[3]})

	oStruALT:AddTrigger( ;
		"XX_PRCREP",	;
		"XX_PRCBRT",	;
		{ || .T. },	;
		{ || ( FwFldGet("XX_PRCREP") + (FwFldGet("XX_PRCREP") * (FwFldGet("XX_MARGEM")/100)) + (FwFldGet("XX_PRCREP") * (FwFldGet("XX_FTPRC")/100)) )})

	oStruALT:AddTrigger( ;
		"XX_LETRA",	;
		"XX_PRCBRT",	;
		{ || .T. },	;
		{ || ( FwFldGet("XX_PRCREP") + (FwFldGet("XX_PRCREP") * (FwFldGet("XX_MARGEM")/100)) + (FwFldGet("XX_PRCREP") * (FwFldGet("XX_FTPRC")/100)) )})

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Manutenção de Tabela de Preço' )

	oModel:GetModel( 'FILMASTER' ):SetOnlyView( .T. )
	oModel:GetModel( 'FILMASTER' ):SetOnlyQuery( .T. )

	oModel:GetModel( 'SB1DETAIL' ):SetOnlyView( .T. )
	oModel:GetModel( 'SB1DETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'SB1DETAIL' ):SetOptional( .T. )

	oModel:GetModel( 'DA1DETAIL' ):SetOnlyView( .T. )
	oModel:GetModel( 'DA1DETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'DA1DETAIL' ):SetOptional( .T. )

	oModel:GetModel( 'ALTDETAIL' ):SetOnlyView( .T. )
	oModel:GetModel( 'ALTDETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'ALTDETAIL' ):SetOptional( .T. )

	oModel:GetModel( 'SB1DETAIL' ):SetMaxLine(99999)

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'FILMASTER' ):SetDescription( 'Manutenção de Tabela de Preço' )
	oModel:GetModel( 'ALTDETAIL' ):SetDescription( 'Manutenção de Tabela de Preço' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Manutenção de Tabela de Preço - Interface com usuário
@author felipe.caiado
@since 13/03/2019
@version undefined

@type function
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   	:= FWLoadModel( 'ANCOM01' )
	// Cria a estrutura a ser usada na View
	Local oStruFIL 	:= FWFormStruct( 2, 'ZZZ')
	Local oStruSB1 	:= FWFormStruct( 2, 'SB1', {|cCampo| Alltrim(cCampo) $ 'B1_COD/B1_DESC/B1_XLINHA'},/*lViewUsado*/ )
	Local oStruDA1 	:= FWFormStruct( 2, 'DA1', {|cCampo| Alltrim(cCampo) $ 'DA1_XTABSQ/DA1_DATVIG/DA1_XPRCBR/DA1_XDESCV/DA1_XPRCLI/DA1_XLETRA/DA1_XPRCRE'},/*lViewUsado*/ )
	Local oStruALT 	:= FWFormStruct( 2, 'ZZZ')
	Local oView
	Local cOrdem 	:= "00"

	cOrdem := Soma1( cOrdem )
	oStruFIL:AddField( ;            	// Ord. Tipo Desc.
	'XX_MARCA'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Marca'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Marca' )				, ; // [04]  C   Descricao do campo
	{ 'Marca' } 					, ; // [05]  A   Array com Help
	'C'                           	, ; // [06]  C   Tipo do campo
	'@!'                			, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruFIL:AddField( ;            	// Ord. Tipo Desc.
	'XX_PRODUT'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Produto'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Produto' )			, ; // [04]  C   Descricao do campo
	{ 'Produto' } 					, ; // [05]  A   Array com Help
	'C'                           	, ; // [06]  C   Tipo do campo
	'@!'                			, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruFIL:AddField( ;            	// Ord. Tipo Desc.
	'XX_LINHA'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Linha'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Linha' )				, ; // [04]  C   Descricao do campo
	{ 'Linha' } 					, ; // [05]  A   Array com Help
	'C'                           	, ; // [06]  C   Tipo do campo
	'@!'                			, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruFIL:AddField( ;            	// Ord. Tipo Desc.
	'XX_CURVA'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Curva'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Curva' )				, ; // [04]  C   Descricao do campo
	{ 'Curva' } 					, ; // [05]  A   Array com Help
	'C'                           	, ; // [06]  C   Tipo do campo
	'@!'                			, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := '99'
	oStruSB1:AddField( ;            	// Ord. Tipo Desc.
	'B1_CURVA'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Crv'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Crv' )				, ; // [04]  C   Descricao do campo
	{ 'Crv' } 					, ; // [05]  A   Array com Help
	'C'                           	, ; // [06]  C   Tipo do campo
	'@!'                			, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo


	cOrdem := "00"
	oStruDA1:AddField( ;            	// Ord. Tipo Desc.
	'DA1_FILIAL'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Filial'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Filial' )				, ; // [04]  C   Descricao do campo
	{ 'Filial' } 					, ; // [05]  A   Array com Help
	'C'                           	, ; // [06]  C   Tipo do campo
	'@!'                			, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := "90"
	oStruDA1:AddField( ;            	// Ord. Tipo Desc.
	'DA1_XCSTAQ'					, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Cst Aquis'    )		, ; // [03]  C   Titulo do campo
	AllTrim( 'Cst Aquis' )			, ; // [04]  C   Descricao do campo
	{ 'Cst Aquis' } 				, ; // [05]  A   Array com Help
	'N'                           	, ; // [06]  C   Tipo do campo
	'@E 9,999.99'                	, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := "91"
	oStruDA1:AddField( ;            	// Ord. Tipo Desc.
	'DA1_XDOC'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Documento'    )		, ; // [03]  C   Titulo do campo
	AllTrim( 'Documento' )			, ; // [04]  C   Descricao do campo
	{ 'Documento' } 				, ; // [05]  A   Array com Help
	'C'                           	, ; // [06]  C   Tipo do campo
	'@!'                			, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := "00"
	cOrdem := Soma1( cOrdem )
	oStruALT:AddField( ;            	// Ord. Tipo Desc.
	'XX_FILIAL'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Filial'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Filial' )				, ; // [04]  C   Descricao do campo
	{ 'Filial' } 					, ; // [05]  A   Array com Help
	'C'                           	, ; // [06]  C   Tipo do campo
	'@!'                			, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruALT:AddField( ;            	// Ord. Tipo Desc.
	'XX_DATA'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Data'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Data' )				, ; // [04]  C   Descricao do campo
	{ 'Data' } 						, ; // [05]  A   Array com Help
	'D'                           	, ; // [06]  C   Tipo do campo
	''                				, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruALT:AddField( ;            	// Ord. Tipo Desc.
	'XX_CSTAQU'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Custo Aquis'    )		, ; // [03]  C   Titulo do campo
	AllTrim( 'Custo Aquis' )		, ; // [04]  C   Descricao do campo
	{ 'Custo Aquis' } 				, ; // [05]  A   Array com Help
	'N'                           	, ; // [06]  C   Tipo do campo
	'@E 999.99'                		, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruALT:AddField( ;            	// Ord. Tipo Desc.
	'XX_PRCREP'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Preço Rep'    )		, ; // [03]  C   Titulo do campo
	AllTrim( 'Preço Rep' )			, ; // [04]  C   Descricao do campo
	{ 'Preço Rep' } 				, ; // [05]  A   Array com Help
	'N'                           	, ; // [06]  C   Tipo do campo
	'@E 999.99'	                	, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruALT:AddField( ;            	// Ord. Tipo Desc.
	'XX_LETRA'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Letra'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Letra' )				, ; // [04]  C   Descricao do campo
	{ 'Letra' } 					, ; // [05]  A   Array com Help
	'C'                           	, ; // [06]  C   Tipo do campo
	'@!'                			, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruALT:AddField( ;            	// Ord. Tipo Desc.
	'XX_MARGEM'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Margem'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Margem' )				, ; // [04]  C   Descricao do campo
	{ 'Margem' } 					, ; // [05]  A   Array com Help
	'N'                           	, ; // [06]  C   Tipo do campo
	'@E 9,999.99'                		, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruALT:AddField( ;            	// Ord. Tipo Desc.
	'XX_FTPRC'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Fator'    )			, ; // [03]  C   Titulo do campo
	AllTrim( 'Fator' )				, ; // [04]  C   Descricao do campo
	{ 'Fator' } 					, ; // [05]  A   Array com Help
	'N'                           	, ; // [06]  C   Tipo do campo
	'@E 9.999'                		, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruALT:AddField( ;            	// Ord. Tipo Desc.
	'XX_PRCBRT'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Preço Bruto'    )		, ; // [03]  C   Titulo do campo
	AllTrim( 'Preço Bruto' )		, ; // [04]  C   Descricao do campo
	{ 'Preço Bruto' } 				, ; // [05]  A   Array com Help
	'N'                           	, ; // [06]  C   Tipo do campo
	'@E 9,999.99'                	, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruALT:AddField( ;            	// Ord. Tipo Desc.
	'XX_DESCONT'					, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Desconto'    )		, ; // [03]  C   Titulo do campo
	AllTrim( 'Desconto' )			, ; // [04]  C   Descricao do campo
	{ 'Desconto' } 					, ; // [05]  A   Array com Help
	'N'                           	, ; // [06]  C   Tipo do campo
	'@E 999.99'                		, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	cOrdem := Soma1( cOrdem )
	oStruALT:AddField( ;            	// Ord. Tipo Desc.
	'XX_PRCLIQ'						, ; // [01]  C   Nome do Campo
	cOrdem							, ; // [02]  C   Ordem
	AllTrim( 'Preço Liq'    )		, ; // [03]  C   Titulo do campo
	AllTrim( 'Preço Liq' )			, ; // [04]  C   Descricao do campo
	{ 'Preço Liq' } 				, ; // [05]  A   Array com Help
	'N'                           	, ; // [06]  C   Tipo do campo
	'@E 9,999.99'                	, ; // [07]  C   Picture
	NIL                             , ; // [08]  B   Bloco de Picture Var
	''                              , ; // [09]  C   Consulta F3
	.T.                             , ; // [10]  L   Indica se o campo é alteravel
	NIL                             , ; // [11]  C   Pasta do campo
	NIL                             , ; // [12]  C   Agrupamento do campo
	NIL				               	, ; // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ; // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ; // [15]  C   Inicializador de Browse
	.T.                             , ; // [16]  L   Indica se o campo é virtual
	NIL                             , ; // [17]  C   Picture Variavel
	NIL                             )   // [18]  L   Indica pulo de linha após o campo

	//Alterar ordens da DA1 na View
	oStruDA1:SetProperty("DA1_XTABSQ", MVC_VIEW_ORDEM , "02")
	oStruDA1:SetProperty("DA1_XLETRA", MVC_VIEW_ORDEM , "03")
	oStruDA1:SetProperty("DA1_DATVIG", MVC_VIEW_ORDEM , "04")
	oStruDA1:SetProperty("DA1_XPRCBR", MVC_VIEW_ORDEM , "05")
	oStruDA1:SetProperty("DA1_XDESCV", MVC_VIEW_ORDEM , "06")
	oStruDA1:SetProperty("DA1_XPRCLI", MVC_VIEW_ORDEM , "07")
	oStruDA1:SetProperty("DA1_XPRCRE", MVC_VIEW_ORDEM , "08")

	oStruSB1:SetProperty("B1_XLINHA", MVC_VIEW_TITULO , "Linha")

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_FIL', oStruFIL, 'FILMASTER' )

	//Adiciona no nosso View um controle do tipo Grid(antiga GetDados)
	oView:AddGrid( 'VIEW_SB1', oStruSB1, 'SB1DETAIL' )
	oView:AddGrid( 'VIEW_DA1', oStruDA1, 'DA1DETAIL' )
	oView:AddGrid( 'VIEW_ALT', oStruALT, 'ALTDETAIL' )

	oView:SetViewProperty( 'VIEW_SB1', "CHANGELINE", {{ |oView, cViewID| AN003(oCodigo, oDescri) }} )
	oView:SetViewProperty( "VIEW_FIL", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP  , 5 } )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'DADOS' , 16 )
	oView:CreateVerticalBox( 'SUPESQ' , 50,'DADOS'  )
	oView:CreateVerticalBox( 'SUPDIR' ,50,'DADOS'  )
	oView:CreateHorizontalBox( 'INFERIOR' , 79 )
	oView:CreateHorizontalBox( 'RODAPE' , 05 )
	oView:CreateVerticalBox( 'INFESQ' , 30,'INFERIOR'  )
	oView:CreateVerticalBox( 'INFDIR' ,70,'INFERIOR'  )
	oView:CreateHorizontalBox( 'INFDIR01' , 50,'INFDIR' )
	oView:CreateHorizontalBox( 'INFDIR02' , 50,'INFDIR' )

	oView:AddOtherObject('VIEW_DPROD', {|oPanel| AN001(@oPanel, @oCodigo, @cCodigo, @oDescri, @cDescri)})

	oView:AddOtherObject('VIEW_RODAPE', {|oPanel| AN001(@oPanel, @oCodigo, @cCodigo, @oDescri, @cDescri)})

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_FIL', 'SUPESQ' )
	oView:SetOwnerView( 'VIEW_DPROD', 'SUPDIR' )
	oView:SetOwnerView( 'VIEW_SB1', 'INFESQ' )
	oView:SetOwnerView( 'VIEW_DA1', 'INFDIR01' )
	oView:SetOwnerView( 'VIEW_ALT', 'INFDIR02' )
	oView:SetOwnerView( 'VIEW_RODAPE', 'RODAPE' )

	oView:AddUserButton( 'Filtro (F12)', 'CLIPS', { |oView| FwMsgRun(Nil,{||AN002(oCodigo, oDescri) },Nil,"Aguarde, Executando Filtro...") },, )
	oView:AddUserButton( 'Salvar (F6)', 'CLIPS', { |oView| FwMsgRun(Nil,{||AN007(lAltLetra,lAltDesc) },Nil,"Aguarde, Atualizando Preço...")},, )
	oView:AddUserButton( 'Alterar Preço (F4)', 'CLIPS', { |oView| lAltLetra := .F., lAltDesc := .F., AN004(lAltLetra, lAltDesc, "Atualização de Preço")},, )
	oView:AddUserButton( 'Altera Letra (CTRL+L)', 'CLIPS', { |oView| lAltLetra := .T., , lAltDesc := .F., AN004(lAltLetra, lAltDesc, "Atualização de Letra")},, )
	oView:AddUserButton( 'Altera Desconto (CTRL+D)', 'CLIPS', { |oView| lAltLetra := .F., lAltDesc := .T., AN004(lAltLetra, lAltDesc, "Atualização de Desconto")},, )

	// Liga a identificacao do componente
	oView:EnableTitleView('VIEW_FIL','Dados do Filtro')
	oView:EnableTitleView('VIEW_DPROD','Dados do Produto')
	oView:EnableTitleView('VIEW_SB1','Produto')
	oView:EnableTitleView('VIEW_ALT','Atualização')
	oView:EnableTitleView('VIEW_DA1','Tabela de Preço')

	oView:SetOnlyView( "VIEW_FIL")
	oView:SetOnlyView( "VIEW_SB1")
	oView:SetOnlyView( "VIEW_DA1")

	//Indica se a janela deve ser fechada ao final da operação. Se ele retornar .T. (verdadeiro) fecha a janela
	oView:bCloseOnOK := {|| .T.}

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} AN001
Cria Objetos
@author felipe.caiado
@since 31/08/2017
@version undefined
@param oPanel, object, Objeto do Painel
@type function
/*/
//-------------------------------------------------------------------
Static Function AN001(oPanel, oCodigo, cCodigo, oDescri, cDescri)

	@ 015,003 Say "Produto" 	Size 020,008 COLOR CLR_BLACK PIXEL OF oPanel
	@ 024,003 MSGET oCodigo VAR cCodigo WHEN .F. SIZE 070, 015 OF oPanel PIXEL
	@ 024,090 MSGET oDescri VAR cDescri WHEN .F. SIZE 200, 015 OF oPanel PIXEL

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN002
Load dos produtos
@author felipe.caiado
@since 13/03/2019
@version 1.0
@param oModelGrid, object, descricao
@param lCopy, logical, descricao
@type function
/*/
//-------------------------------------------------------------------
Static Function AN002(oCodigo, oDescri)

	Local aLoad 		:= {}
	Local aRet as array
	Local aPerg as array
	Local oModel     	:= FWModelActive()
	Local oModelSB1  	:= oModel:GetModel( 'SB1DETAIL' )
	Local oModelDA1  	:= oModel:GetModel( 'DA1MASTER' )
	Local oModelALT  	:= oModel:GetModel( 'ALTDETAIL' )
	Local nLinhaSB1  	:= 1
	Local cAliasSB1		:= GetNextAlias()
	Local cWhere		:= ""
	Local oView			:= FwViewActive()
	Local aCurva		:= {}

	aRet 	:= {}
	aPerg	:= {}

	lCopPRep := .F.

	aAdd( aPerg ,{1,Alltrim("Marca"),Space(10),"@!",".T.","","",40,.F.})
	aAdd( aPerg ,{1,Alltrim("Produto"),Space(15),"@!",".T.","","",40,.F.})
	aAdd( aPerg ,{1,Alltrim("Linha"),Space(10),"@!",".T.","","",40,.F.})
	aAdd( aPerg ,{1,Alltrim("Curva"),Space(10),"@!",".T.","","",40,.F.})

	If !ParamBox(aPerg ,"Filtros",@aRet)
		Return()
	EndIf

	If Empty(MV_PAR01) .And. Empty(MV_PAR02) .And. Empty(MV_PAR03)
		ApMsgInfo("Favor preencher algum filtro")
		Return()
	EndIf

	aCurva := U_Calc_Curv(Alltrim(MV_PAR01), StoD("20190101"), StoD("20191231"), "V" )

	//Limpa o Grid
	oModelSB1:ClearData(.F.,.T.)
	oModelALT:ClearData(.F.,.T.)

	oModel:GetModel("FILMASTER"):GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{|| .T.})

	oModel:GetModel("FILMASTER"):SetValue("XX_MARCA",Alltrim(MV_PAR01))
	oModel:GetModel("FILMASTER"):SetValue("XX_PRODUT",Alltrim(MV_PAR02))
	oModel:GetModel("FILMASTER"):SetValue("XX_LINHA",Alltrim(MV_PAR03))
	oModel:GetModel("FILMASTER"):SetValue("XX_CURVA",Alltrim(MV_PAR04))

	oModel:GetModel("FILMASTER"):GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{|| .F.})

	If !Empty(MV_PAR01)
		cWhere += " AND B1_XMARCA = '" + MV_PAR01 + "'"
	EndIf

	If !Empty(MV_PAR02)
		cWhere += " AND B1_COD = '" + MV_PAR02 + "'"
	EndIf

	If !Empty(MV_PAR03)
		cWhere += " AND B1_XLINHA = '" + MV_PAR03 + "'"
	EndIf

	cWhere := "%" + cWhere + "%"

	BeginSQL alias cAliasSB1
		SELECT
			B1_COD,
			B1_DESC,
			B1_XLINHA
		FROM
			%table:SB1% SB1
		WHERE
			B1_FILIAL = %xFilial:SB1%
			AND B1_MSBLQL <> '1'
			AND SB1.%notDel%
			%exp:cWhere%
		ORDER BY
			B1_XMARCA,
			B1_XLINHA,
			B1_COD
	EndSql

	While (cAliasSB1)->( !Eof() )

		nPos := aScan(aCurva,{|x| Alltrim(x[1]) == Alltrim((cAliasSB1)->B1_COD)})

		If !Empty(MV_PAR04)

			If nPos > 0
				If !Alltrim(aCurva[nPos][6]) $ Alltrim(MV_PAR04)
					(cAliasSB1)->(DbSkip())
					Loop
				EndIf
			EndIf

		EndIf

		oModelSB1:SetNoInsertLine(.F.)

		If nLinhaSB1 > 1
			If oModelSB1:AddLine() <> nLinhaSB1
				Help( ,, 'HELP',, 'Nao incluiu linha SB1' + CRLF + oModel:getErrorMessage()[6], 1, 0)
				(cAliasSB1)->(DbSkip())
				Loop
			EndIf
		EndIf

		oModelSB1:SetNoInsertLine(.T.)

		lUpdCNF := oModelSB1:CanUpdateLine()

		If !lUpdCNF
			oModelSB1:SetNoUpdateLine(.F.)
		EndIf

		oModelSB1:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

		oModelSB1:SetValue( 'B1_COD',(cAliasSB1)->B1_COD )
		oModelSB1:SetValue( 'B1_DESC',Substr((cAliasSB1)->B1_DESC,1,20) )
		oModelSB1:SetValue( 'B1_XLINHA',(cAliasSB1)->B1_XLINHA )
		oModelSB1:SetValue( 'B1_CURVA',Alltrim(aCurva[nPos][6]) )

		oModelSB1:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.F.})

		oModelSB1:SetNoUpdateLine(!lUpdCNF)

		nLinhaSB1++

		(cAliasSB1)->(DbSkip())

	Enddo

	(cAliasSB1)->(DbCloseArea())

	oModelSB1:GoLine(1)

	oView:Refresh('VIEW_SB1')

	oView:Refresh('VIEW_ALT')

	AN003(oCodigo, oDescri)

Return(aLoad)

//-------------------------------------------------------------------
/*/{Protheus.doc} AN003
Atualiza registro do produto
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function AN003(oCodigo, oDescri)

	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oModelSB1  	:= oModel:GetModel( 'SB1DETAIL' )
	Local oModelDA1  	:= oModel:GetModel( 'DA1DETAIL' )
	Local nLinhaDA1  	:= 1
	Local cAliasDA1		:= GetNextAlias()

	cCodigo := oModelSB1:GetValue("B1_COD")
	cDescri := Posicione("SB1",1,xFilial("SB1")+oModelSB1:GetValue("B1_COD"),"B1_DESC")

	oCodigo:Refresh()
	oDescri:Refresh()

	oView:Refresh('VIEW_DPROD')

	BeginSQL alias cAliasDA1
		SELECT
			DA1_FILIAL,
			DA1_XTABSQ,
			DA1_DATVIG,
			DA1_XPRCBR,
			DA1_XDESCV,
			DA1_XPRCLI,
			DA1_XLETRA,
			DA1_XPRCRE,
			DA1_CODPRO
		FROM
			%table:DA1% DA1
		WHERE
			DA1_FILIAL BETWEEN '      ' AND 'ZZZZZZ'
			AND DA1_CODPRO = %exp:cCodigo%
			AND DA1.%notDel%
		ORDER BY
			DA1_XTABSQ,
			DA1_FILIAL
	EndSql

	//Limpa o Grid
	oModelDA1:ClearData(.F.,.T.)

	While (cAliasDA1)->( !Eof() )

		oModelDA1:SetNoInsertLine(.F.)

		If nLinhaDA1 > 1
			If oModelDA1:AddLine() <> nLinhaDA1
				Help( ,, 'HELP',, 'Nao incluiu linha SB1' + CRLF + oModel:getErrorMessage()[6], 1, 0)
				Loop
			EndIf
		EndIf

		oModelDA1:SetNoInsertLine(.T.)

		lUpdCNF := oModelDA1:CanUpdateLine()

		If !lUpdCNF
			oModelDA1:SetNoUpdateLine(.F.)
		EndIf

		oModelDA1:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

		oModelDA1:SetValue( 'DA1_FILIAL',(cAliasDA1)->DA1_FILIAL )
		oModelDA1:SetValue( 'DA1_DATVIG',StoD((cAliasDA1)->DA1_DATVIG) )
		oModelDA1:SetValue( 'DA1_XTABSQ',(cAliasDA1)->DA1_XTABSQ )
		oModelDA1:SetValue( 'DA1_XPRCBR',(cAliasDA1)->DA1_XPRCBR )
		oModelDA1:SetValue( 'DA1_XDESCV',(cAliasDA1)->DA1_XDESCV )
		oModelDA1:SetValue( 'DA1_XPRCRE',(cAliasDA1)->DA1_XPRCRE )
		oModelDA1:SetValue( 'DA1_XTABSQ',(cAliasDA1)->DA1_XTABSQ )
		oModelDA1:SetValue( 'DA1_XLETRA',(cAliasDA1)->DA1_XLETRA )
		oModelDA1:SetValue( 'DA1_XPRCLI',(cAliasDA1)->DA1_XPRCLI )
		oModelDA1:SetValue( 'DA1_XCSTAQ',AN005((cAliasDA1)->DA1_FILIAL,(cAliasDA1)->DA1_CODPRO, 1) )
		oModelDA1:SetValue( 'DA1_XDOC'  ,AN005((cAliasDA1)->DA1_FILIAL,(cAliasDA1)->DA1_CODPRO, 2) )

		oModelDA1:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.F.})

		oModelDA1:SetNoUpdateLine(!lUpdCNF)

		nLinhaDA1++

		(cAliasDA1)->(DbSkip())

	Enddo

	(cAliasDA1)->(DbCloseArea())

	oModelDA1:GoLine(1)

	oView:Refresh('VIEW_DA1')

	oView:Refresh('VIEW_FIL')

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN004
Atualiza o grid de Alteração
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function AN004(lAltLetra, lAltDesc, cDescri)

	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oModelALT  	:= oModel:GetModel( 'ALTDETAIL' )
	Local nLinhaALT  	:= 1
	Local nX			:= 0

	lCopPRep := .F.

	//Limpa o Grid
	oModelALT:ClearData(.F.,.T.)

	//Dados do SM0
	aSM0 := FWLoadSM0(.T.)

	For nX:=1 To Len(aSM0)

		If Substr(aSM0[nX][SM0_FILIAL],1,2) <> "02"
			Loop
		EndIF

		oModelALT:SetNoInsertLine(.F.)

		If nLinhaALT > 1
			If oModelALT:AddLine() <> nLinhaALT
				Help( ,, 'HELP',, 'Nao incluiu linha SB1' + CRLF + oModel:getErrorMessage()[6], 1, 0)
				Loop
			EndIf
		EndIf

		oModelALT:SetNoInsertLine(.T.)

		lUpdCNF := oModelALT:CanUpdateLine()

		If !lUpdCNF
			oModelALT:SetNoUpdateLine(.F.)
		EndIf

		oModelALT:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,{||.T.})

		oModelALT:SetValue( 'XX_FILIAL'		, aSM0[nX][SM0_FILIAL])
		oModelALT:SetValue( 'XX_DATA'		,CtoD('  /  /  ') )
		oModelALT:SetValue( 'XX_CSTAQU'		,0)
		oModelALT:SetValue( 'XX_PRCREP'		,0 )
		oModelALT:SetValue( 'XX_LETRA'		," " )
		oModelALT:SetValue( 'XX_MARGEM'		,0 )
		oModelALT:SetValue( 'XX_FTPRC'		,0 )
		oModelALT:SetValue( 'XX_PRCBRT'		,0 )
		oModelALT:SetValue( 'XX_DESCONT'	,0 )
		oModelALT:SetValue( 'XX_PRCLIQ'		,0 )

		If lAltLetra
			oModelALT:GetStruct():SetProperty('XX_FILIAL',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_CSTAQU',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_MARGEM',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_FTPRC',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_PRCBRT',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_PRCLIQ',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_DESCONT',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_PRCREP',MODEL_FIELD_WHEN,{||.F.})
		ElseIf lAltDesc
			oModelALT:GetStruct():SetProperty('XX_FILIAL',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_CSTAQU',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_MARGEM',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_FTPRC',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_PRCBRT',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_PRCLIQ',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_LETRA',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_PRCREP',MODEL_FIELD_WHEN,{||.F.})
		Else
			oModelALT:GetStruct():SetProperty('XX_FILIAL',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_CSTAQU',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_MARGEM',MODEL_FIELD_WHEN,{||.F.})
			oModelALT:GetStruct():SetProperty('XX_FTPRC',MODEL_FIELD_WHEN,{||.F.})
		EndIf

		oModelALT:SetNoUpdateLine(!lUpdCNF)

		nLinhaALT++

	Next

	//Atualiza titulo da view
	oView:EnableTitleView( "VIEW_ALT", cDescri )
	oView:aViews[4,3]:cTitle := cDescri

	oView:Refresh('VIEW_RODAPE')

	oModelALT:GoLine(1)

	oView:EnableTitleView('VIEW_ALT','FELIPE')

	oView:Refresh('VIEW_ALT')

	oView:GetViewObj("VIEW_ALT")[3]:oBrowse:oBrowse:SetFocus()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN005
Busca o último Custo de Compra
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function AN005(cFilNF, cProduto, nTipo)

	Local cAliasSD1		:= GetNextAlias()
	Local xRet

	BeginSQL alias cAliasSD1
		SELECT
			D1_VUNIT,
			D1_DOC
		FROM
			%table:SD1% SD1
		WHERE
			D1_FILIAL = %exp:cFilNf%
			AND D1_COD = %exp:cProduto%
			AND SD1.%notDel%
			AND SD1.R_E_C_N_O_ = (SELECT
					MAX(SD11.R_E_C_N_O_)
				FROM
					%table:SD1% SD11
				WHERE
					SD11.%notDel%
					AND D1_FILIAL = %exp:cFilNf%
					AND D1_COD = %exp:cProduto%)
	EndSql

	If (cAliasSD1)->(Eof())
		If nTipo == 1
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+cProduto))
				xRet := SB1->B1_UPRC
			EndIf
		Else
			xRet := ""
		EndIf
	Else
		If nTipo == 1
			xRet := (cAliasSD1)->D1_VUNIT
		Else
			xRet := (cAliasSD1)->D1_DOC
		EndIf
	EndIf

	(cAliasSD1)->(DbCloseArea())

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AN006
Posiciona na Tabela de Preço
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function AN006(cFilNF, cProduto, cCampo, cTabela)

	Local cAliasDA1		:= GetNextAlias()
	Local nRet			:= 0
	Local cCodDA0		:= Alltrim(SuperGetMv("AN_TABPRC",.F.,"100"))

	DbSelectArea("DA1")
	DA1->(DbSetOrder(1))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO
	If DA1->(DbSeek(cFilNF+cCodDA0+cProduto))

		While !DA1->(Eof()) .And. cFilNF+cCodDA0+cProduto == DA1->DA1_FILIAL+DA1->DA1_CODTAB+DA1->DA1_CODPRO

			If DA1->DA1_XTABSQ == cTabela
				nRet := DA1->&(cCampo)
			EndIf

			DA1->(DbSkip())

		EndDo

	EndIf

Return(nRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AN007
Salva os dados
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function AN007(lAltLetra,lAltDesc)

	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oModelSB1  	:= oModel:GetModel( 'SB1DETAIL' )
	Local oModelALT  	:= oModel:GetModel( 'ALTDETAIL' )
	Local oModelFIL  	:= oModel:GetModel( 'FILMASTER' )
	Local nT			:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nA			:= 0
	Local nB			:= 0
	Local cAliasDA1		:= GetNextAlias()
	Local cAliasITE		:= GetNextAlias()
	Local cCodDA0		:= Alltrim(SuperGetMv("AN_TABPRC",.F.,"100"))
	Local cMsg			:= ""
	Local lProd			:= .F.
	Local cProd			:= oModelSB1:GetValue("B1_COD")
	Local nPRep			:= 0

	If lAltLetra
		cMsg := "Confirma a atualização da tabela por LETRA?" + CRLF
	ElseIf lAltDesc
		cMsg := "Confirma a atualização da tabela por DESCONTO?"
	Else
		cMsg := "Confirma a atualização da tabela por PREÇO"
	EndIf

	cMsg += CRLF
	cMsg += "---------------------------------" + CRLF
	cMsg += "FILTRO UTILIZADO:" + CRLF
	cMsg += "---------------------------------" + CRLF
	cMsg += CRLF
	cMsg += "MARCA: " + oModelFIL:GetValue("XX_MARCA") + CRLF
	cMsg += "PRODUTO: " + oModelFIL:GetValue("XX_PRODUT") + CRLF
	cMsg += "LINHA: " + oModelFIL:GetValue("XX_LINHA") + CRLF
	cMsg += "CURVA: " + oModelFIL:GetValue("XX_CURVA")

	If !ApMsgNoYes(cMsg) //Se for não a resposta pergunta se quer fazer por produto

		lProd := ApMsgNoYes("Deseja fazer a atualização do produto " + Alltrim(cCodigo) + "-" + Alltrim(cDescri))

		If !lProd

			Return()

		EndIf
	EndIf

	For nX := 1 to oModelSB1:Length()

		oModelSB1:GoLine(nX)

		If lProd
			If Alltrim(cCodigo) <> Alltrim(oModelSB1:GetValue("B1_COD"))
				Loop
			EndIf
		EndIf

		For nY := 1 to oModelALT:Length()

			oModelALT:GoLine(nY)

			If Alltrim(oModelALT:GetValue("XX_FILIAL")) == "020101"
				DbSelectArea("DA1")
				DA1->(DbOrderNickName("DA1SEQ"))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_XTABSQ
				If DA1->(DbSeek(oModelALT:GetValue("XX_FILIAL")+cCodDA0+oModelSB1:GetValue("B1_COD")))
					nPRep := DA1->DA1_XPRCRE
				EndIf
			EndIf

			If !Empty(oModelALT:GetValue("XX_DATA"))

				lCriaReg := .T.

				cTabProc 	:= ""
				aTabSeq		:= {}
				aTabDel		:= {}

				lAtualiz	:= .F.

				DbSelectArea("DA1")
				DA1->(DbOrderNickName("DA1SEQ"))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_XTABSQ
				If DA1->(DbSeek(oModelALT:GetValue("XX_FILIAL")+cCodDA0+oModelSB1:GetValue("B1_COD")))

					While !DA1->(Eof()) .And. oModelALT:GetValue("XX_FILIAL")+cCodDA0+oModelSB1:GetValue("B1_COD") == DA1->DA1_FILIAL+DA1->DA1_CODTAB+DA1->DA1_CODPRO

						//Verifica se é menor que a tabela 1
						If DA1->DA1_DATVIG > oModelALT:GetValue("XX_DATA")

							DA1->(DbSkip())
							Loop

						ElseIf DA1->DA1_DATVIG == oModelALT:GetValue("XX_DATA")

							lCriaReg := .F.

							If lAltLetra
								Reclock("DA1",.F.)
								DA1->DA1_XLETRA := Upper(oModelALT:GetValue("XX_LETRA"))
								DA1->DA1_XFATOR := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[3]
								DA1->DA1_XMARGE := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[1]
								DA1->DA1_XPRCBR := ( DA1->DA1_XPRCRE + (DA1->DA1_XPRCRE * (DA1->DA1_XMARGE/100)) + (DA1->DA1_XPRCRE * (DA1->DA1_XFATOR/100)) )
								nPrcVen := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[4]
								nPreco := nPrcVen - (nPrcVen *(DA1->DA1_XDESCV/100))
								DA1->DA1_XPRCLI := nPreco
								DA1->DA1_PRCVEN := nPreco
								DA1->(MsUnlock())
							ElseIf lAltDesc
								Reclock("DA1",.F.)
								DA1->DA1_XDESCV := oModelALT:GetValue("XX_DESCONT")
//								DA1->DA1_XPRCBR := ( DA1->DA1_XPRCRE + (DA1->DA1_XPRCRE * (DA1->DA1_XMARGE/100)) + (DA1->DA1_XPRCRE * (DA1->DA1_XFATOR/100)) )
								nPrcVen := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[4]
								nPreco := nPrcVen - (nPrcVen *(DA1->DA1_XDESCV/100))
								DA1->DA1_XPRCLI := nPreco
								DA1->DA1_PRCVEN := nPreco
								DA1->(MsUnlock())
							Else
								Reclock("DA1",.F.)
								DA1->DA1_XLETRA := Upper(oModelALT:GetValue("XX_LETRA"))
								DA1->DA1_XDESCV := oModelALT:GetValue("XX_DESCONT")
								If cProd == oModelSB1:GetValue("B1_COD")
									DA1->DA1_XPRCBR := oModelALT:GetValue("XX_PRCBRT")
									DA1->DA1_XPRCLI := oModelALT:GetValue("XX_PRCLIQ")
									DA1->DA1_PRCVEN := oModelALT:GetValue("XX_PRCLIQ")
									DA1->DA1_XPRCRE := oModelALT:GetValue("XX_PRCREP")
								Else
									If lCopPRep
										DA1->DA1_XPRCRE := nPRep
									EndIf
									DA1->DA1_XFATOR := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[3]
									DA1->DA1_XMARGE := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[1]
									DA1->DA1_XPRCBR := ( DA1->DA1_XPRCRE + (DA1->DA1_XPRCRE * (DA1->DA1_XMARGE/100)) + (DA1->DA1_XPRCRE * (DA1->DA1_XFATOR/100)) )
									nPrcVen := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[4]
									nPreco := nPrcVen - (nPrcVen *(DA1->DA1_XDESCV/100))
									DA1->DA1_XPRCLI := nPreco
									DA1->DA1_PRCVEN := nPreco
								EndIf
								DA1->(MsUnlock())
							EndIf

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
						For nT:=1 To Len(aTabSeq)
							DA1->(DbGoTo(aTabSeq[nT][1]))
							Reclock("DA1",.F.)
								DA1->DA1_XTABSQ := aTabSeq[nT][2]
							DA1->(MsUnlock())
						Next nT

						cTabProx := Soma1(cTabProc)

						//Localiza a vigencia da tabela 1
						BeginSQL alias cAliasDA1
						SELECT
							R_E_C_N_O_ RECNUM
						FROM
							%table:DA1% DA1
						WHERE
							DA1_FILIAL = %exp:oModelALT:GetValue("XX_FILIAL")%
							AND DA1_CODPRO = %exp:oModelSB1:GetValue("B1_COD")%
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
							DA1_FILIAL = %exp:oModelALT:GetValue("XX_FILIAL")%
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

							Next na

							nB := 0

							Reclock("DA1",.T.)

							For nB:=1 To Len(aReg)

								If Alltrim(aReg[nB][1]) == "DA1_XTABSQ"
									DA1->DA1_XTABSQ := cTabProc
									Loop
								EndIf

								If Alltrim(aReg[nB][1]) == "DA1_DATVIG"
									DA1->DA1_DATVIG := oModelALT:GetValue("XX_DATA")
									Loop
								EndIf

								If Alltrim(aReg[nB][1]) == "DA1_ITEM"
									DA1->DA1_ITEM := Soma1(cItem)
									Loop
								EndIf

								DA1->&( aReg[nB][1] ) := aReg[nB][2]

							Next nB

							DA1->(MsUnlock())

							If lAltLetra
								Reclock("DA1",.F.)
								DA1->DA1_XLETRA := Upper(oModelALT:GetValue("XX_LETRA"))
								DA1->DA1_XFATOR := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[3]
								DA1->DA1_XMARGE := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[1]
								DA1->DA1_XPRCBR := ( DA1->DA1_XPRCRE + (DA1->DA1_XPRCRE * (DA1->DA1_XMARGE/100)) + (DA1->DA1_XPRCRE * (DA1->DA1_XFATOR/100)) )
								nPrcVen := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[4]
								nPreco := nPrcVen - (nPrcVen *(DA1->DA1_XDESCV/100))
								DA1->DA1_XPRCLI := nPreco
								DA1->DA1_PRCVEN := nPreco
								DA1->(MsUnlock())
							ElseIf lAltDesc
								Reclock("DA1",.F.)
								DA1->DA1_XDESCV := oModelALT:GetValue("XX_DESCONT")
//								DA1->DA1_XPRCBR := ( DA1->DA1_XPRCRE + (DA1->DA1_XPRCRE * (DA1->DA1_XMARGE/100)) + (DA1->DA1_XPRCRE * (DA1->DA1_XFATOR/100)) )
								nPrcVen := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[4]
								nPreco := nPrcVen - (nPrcVen *(DA1->DA1_XDESCV/100))
								DA1->DA1_XPRCLI := nPreco
								DA1->DA1_PRCVEN := nPreco
								DA1->(MsUnlock())
							Else
								Reclock("DA1",.F.)
								DA1->DA1_XLETRA := Upper(oModelALT:GetValue("XX_LETRA"))
								DA1->DA1_XDESCV := oModelALT:GetValue("XX_DESCONT")
								If cProd == oModelSB1:GetValue("B1_COD")
									DA1->DA1_XPRCBR := oModelALT:GetValue("XX_PRCBRT")
									DA1->DA1_XPRCLI := oModelALT:GetValue("XX_PRCLIQ")
									DA1->DA1_PRCVEN := oModelALT:GetValue("XX_PRCLIQ")
									DA1->DA1_XPRCRE := oModelALT:GetValue("XX_PRCREP")
								Else
									If lCopPRep
										DA1->DA1_XPRCRE := nPRep
									EndIf
									DA1->DA1_XFATOR := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[3]
									DA1->DA1_XMARGE := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[1]
									DA1->DA1_XPRCBR := ( DA1->DA1_XPRCRE + (DA1->DA1_XPRCRE * (DA1->DA1_XMARGE/100)) + (DA1->DA1_XPRCRE * (DA1->DA1_XFATOR/100)) )
									nPrcVen := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[4]
									nPreco := nPrcVen - (nPrcVen *(DA1->DA1_XDESCV/100))
									DA1->DA1_XPRCLI := nPreco
									DA1->DA1_PRCVEN := nPreco
								EndIf
								DA1->(MsUnlock())
							EndIf

							//Deleta Os registros
							nT := 0
							For nT:=1 To Len(aTabDel)
								DA1->(DbGoTo(aTabDel[nT]))
								Reclock("DA1",.F.)
									DA1->(DbDelete())
								DA1->(MsUnlock())
							Next nT

							(cAliasDA1)->(DbSkip())
						EndDo

						(cAliasDA1)->(DbCloseArea())

					EndIf

				EndIf

			EndIf

		Next nY

	Next nX

	oModelALT:GoLine(1)

	oView:Refresh('VIEW_ALT')

	ApMsgInfo("Atualização efetuada com sucesso")

	oModelALT:ClearData(.F.,.T.)

	lCopPRep := .F.

	oView:GetViewObj("VIEW_SB1")[3]:oBrowse:oBrowse:SetFocus()

	oView:Refresh('VIEW_ALT')

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN008
Altera preço liquido
@author felipe.caiado
@since 15/03/2019
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Static Function AN008()

	Local nRet as numeric
	Local nPrcVen as numeric

	nRet := 0
	//Preço de Venda
	nPrcVen := u_CalcPrcV(Upper(Alltrim(FwFldGet("XX_LETRA"))), cCodigo, FwFldGet("XX_FILIAL"), FwFldGet("XX_PRCREP"))[4]

	nRet := nPrcVen - (nPrcVen *(FwFldGet("XX_DESCONT")/100))

Return(nRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AN009
Replica os dados
@author felipe.caiado
@since 15/03/2019
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Static Function AN009(lAltLetra,lAltDesc)

	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oModelALT  	:= oModel:GetModel( 'ALTDETAIL' )
	Local nY			:= 0

	//So executa se a filial for igual de 020101
	If !FwFldGet("XX_FILIAL") = '020101'
		Return()
	EndIf

	If ApMsgYesNo("Deseja Repicar as informações para as outras filiais?")

		For nY := 1 to oModelALT:Length()

			oModelALT:GoLine(nY)

			//Guarda a data da primeira filial
			If nY == 1
				dData := oModelALT:GetValue("XX_DATA")
				cLetra := oModelALT:GetValue("XX_LETRA")
				nDescon := oModelALT:GetValue("XX_DESCONT")
				nReposic := oModelALT:GetValue("XX_PRCREP")
			EndIf

			If oModelALT:GetValue("XX_FILIAL") <> "020101"

				aViewCp		:= aclone(oView:GetViewStruct('VIEW_ALT'):Getfields())
				nPData 		:= aScan( aViewCp, { |x| AllTrim( x[ MVC_VIEW_IDFIELD ] ) ==  AllTrim( 'XX_DATA' ) } )
				nPDescon 	:= aScan( aViewCp, { |x| AllTrim( x[ MVC_VIEW_IDFIELD ] ) ==  AllTrim( 'XX_DESCONT' ) } )
				nPLetra 	:= aScan( aViewCp, { |x| AllTrim( x[ MVC_VIEW_IDFIELD ] ) ==  AllTrim( 'XX_LETRA' ) } )
				nPRepos 	:= aScan( aViewCp, { |x| AllTrim( x[ MVC_VIEW_IDFIELD ] ) ==  AllTrim( 'XX_PRCREP' ) } )
				nCol		:= oView:GetViewObj("VIEW_ALT")[3]:obrowse:obrowse:ColPos()						//Coluna no Momento do click  do F4, Qdo no Grid

				If nCol == nPData//Data
					oModelALT:SetValue("XX_DATA", dData)
				ElseIf nCol == nPLetra//Letra
					oModelALT:SetValue("XX_LETRA", cLetra)
				ElseIf nCol == nPDescon//Desconto
					oModelALT:SetValue("XX_DESCONT", nDescon)
				ElseIf nCol == nPRepos//Preço Reposição
					oModelALT:SetValue("XX_PRCREP", nReposic)
					lCopPRep := .T.
				EndIf

			EndIf

		Next nY

	EndIF

	oModelALT:GoLine(1)

	oView:EnableTitleView('VIEW_ALT','Atualização1')

	oView:Refresh('VIEW_ALT')

	oView:GetViewObj("VIEW_ALT")[3]:oBrowse:oBrowse:SetFocus()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN010
Copia de Tabela de Preço entra filiais
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function AN010()

	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oModelSB1  	:= oModel:GetModel( 'SB1DETAIL' )
	Local oModelALT  	:= oModel:GetModel( 'ALTDETAIL' )
	Local oModelFIL  	:= oModel:GetModel( 'FILMASTER' )
	Local nT			:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nA			:= 0
	Local nB			:= 0
	Local cAliasDA1		:= GetNextAlias()
	Local cAliasITE		:= GetNextAlias()
	Local cCodDA0		:= Alltrim(SuperGetMv("AN_TABPRC",.F.,"100"))
	Local cMsg			:= ""
	Local lProd			:= .F.
	Local lAtuLetra		:= .F.
	Local lAtuDesc		:= .F.
	Local lAtuPRep		:= .F.
	Local aRet as array
	Local aPerg as array

	aRet 	:= {}
	aPerg	:= {}

	aAdd( aPerg ,{1,Alltrim("Filial Origem"),Space(06),"@!",".T.","SM0","",30,.F.})
	aAdd( aPerg ,{1,Alltrim("Filial Destino"),Space(06),"@!",".T.","SM0","",30,.F.})
	aAdd( aPerg ,{1,Alltrim("Tabela"),Space(1),"@!",".T.","","",10,.F.})
	aAdd( aPerg ,{2,Alltrim("Copia preço de reposição"),"S",{"S=Sim","N=Não"},40,"",.F.})
	aAdd( aPerg ,{2,Alltrim("Manter letra da tabela de destino"),"S",{"S=Sim","N=Não"},40,"",.F.})
	aAdd( aPerg ,{2,Alltrim("Manter desconto da tabela de destino"),"S",{"S=Sim","N=Não"},40,"",.F.})

	If !ParamBox(aPerg ,"Cópia de Tabela",@aRet)
		Return()
	EndIf

	//Verifica se está vazio os parâmetros
	If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03)
		ApMsgInfo("Favor preencher todos os parâmetros")
		Return()
	EndIf

	lAtuLetra		:= Alltrim(MV_PAR05) == "N"
	lAtuDesc		:= Alltrim(MV_PAR06) == "N"
	lAtuPRep		:= Alltrim(MV_PAR04) == "S"

	cMsg := "Confirma a Cópia da Filial " + MV_PAR01 + " para a Filial " + MV_PAR02 + "?" + CRLF

	cMsg += CRLF
	cMsg += "---------------------------------" + CRLF
	cMsg += "FILTRO UTILIZADO:" + CRLF
	cMsg += "---------------------------------" + CRLF
	cMsg += CRLF
	cMsg += "MARCA: " + oModelFIL:GetValue("XX_MARCA") + CRLF
	cMsg += "PRODUTO: " + oModelFIL:GetValue("XX_PRODUT") + CRLF
	cMsg += "LINHA: " + oModelFIL:GetValue("XX_LINHA") + CRLF
	cMsg += "CURVA: " + oModelFIL:GetValue("XX_CURVA")

	If !ApMsgNoYes(cMsg) //Se for não a resposta pergunta se quer fazer por produto

		lProd := ApMsgNoYes("Deseja fazer a cópia do produto " + Alltrim(cCodigo) + "-" + Alltrim(cDescri))

		If !lProd

			Return()

		EndIf
	EndIf

	For nX := 1 to oModelSB1:Length()

		oModelSB1:GoLine(nX)

		If lProd
			If Alltrim(cCodigo) <> Alltrim(oModelSB1:GetValue("B1_COD"))
				Loop
			EndIf
		EndIf

		lCriaReg := .T.

		cTabProc 	:= ""
		aTabSeq		:= {}
		aTabDel		:= {}

		lAtualiz	:= .F.

		dData := AN006(MV_PAR01, oModelSB1:GetValue("B1_COD"), "DA1_DATVIG", MV_PAR03)
		cLetra := AN006(MV_PAR01, oModelSB1:GetValue("B1_COD"), "DA1_XLETRA", MV_PAR03)
		nDescont := AN006(MV_PAR01, oModelSB1:GetValue("B1_COD"), "DA1_XDESCV", MV_PAR03)
		nPreRep := AN006(MV_PAR01, oModelSB1:GetValue("B1_COD"), "DA1_XPRCRE", MV_PAR03)

		DbSelectArea("DA1")
		DA1->(DbOrderNickName("DA1SEQ"))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_XTABSQ
		If DA1->(DbSeek(Alltrim(MV_PAR02)+cCodDA0+oModelSB1:GetValue("B1_COD")))

			While !DA1->(Eof()) .And. Alltrim(MV_PAR02)+cCodDA0+oModelSB1:GetValue("B1_COD") == DA1->DA1_FILIAL+DA1->DA1_CODTAB+DA1->DA1_CODPRO

				//Verifica se é menor que a tabela 1
				If DA1->DA1_DATVIG > dData

					DA1->(DbSkip())
					Loop

				ElseIf DA1->DA1_DATVIG == dData

					lCriaReg := .F.

					Reclock("DA1",.F.)
					If lAtuLetra
						DA1->DA1_XLETRA := Upper(cLetra)
						DA1->DA1_XFATOR := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[3]
						DA1->DA1_XMARGE := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[1]
					EndIf

					If lAtuDesc
						DA1->DA1_XDESCV := nDescont
					EndIf

					If lAtuPRep
						DA1->DA1_XPRCRE := nPreRep
					EndIf

					DA1->DA1_XPRCBR := ( DA1->DA1_XPRCRE + (DA1->DA1_XPRCRE * (DA1->DA1_XMARGE/100)) + (DA1->DA1_XPRCRE * (DA1->DA1_XFATOR/100)) )
					nPrcVen := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[4]
					nPreco := nPrcVen - (nPrcVen *(DA1->DA1_XDESCV/100))
					DA1->DA1_XPRCLI := nPreco
					DA1->DA1_PRCVEN := nPreco
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
				For nT:=1 To Len(aTabSeq)
					DA1->(DbGoTo(aTabSeq[nT][1]))
					Reclock("DA1",.F.)
						DA1->DA1_XTABSQ := aTabSeq[nT][2]
					DA1->(MsUnlock())
				Next nT

				cTabProx := Soma1(cTabProc)

				//Localiza a vigencia da tabela 1
				BeginSQL alias cAliasDA1
				SELECT
					R_E_C_N_O_ RECNUM
				FROM
					%table:DA1% DA1
				WHERE
					DA1_FILIAL = %exp:MV_PAR02%
					AND DA1_CODPRO = %exp:oModelSB1:GetValue("B1_COD")%
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
					DA1_FILIAL = %exp:MV_PAR02%
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

					Next na

					nB := 0

					Reclock("DA1",.T.)

					For nB:=1 To Len(aReg)

						If Alltrim(aReg[nB][1]) == "DA1_XTABSQ"
							DA1->DA1_XTABSQ := cTabProc
							Loop
						EndIf

						If Alltrim(aReg[nB][1]) == "DA1_DATVIG"
							DA1->DA1_DATVIG := dData
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
					If lAtuLetra
						DA1->DA1_XLETRA := Upper(cLetra)
						DA1->DA1_XFATOR := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[3]
						DA1->DA1_XMARGE := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[1]
					EndIf

					If lAtuDesc
						DA1->DA1_XDESCV := nDescont
					EndIf

					If lAtuPRep
						DA1->DA1_XPRCRE := nPreRep
					EndIf

					DA1->DA1_XPRCBR := ( DA1->DA1_XPRCRE + (DA1->DA1_XPRCRE * (DA1->DA1_XMARGE/100)) + (DA1->DA1_XPRCRE * (DA1->DA1_XFATOR/100)) )
					nPrcVen := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[4]
					nPreco := nPrcVen - (nPrcVen *(DA1->DA1_XDESCV/100))
					DA1->DA1_XPRCLI := nPreco
					DA1->DA1_PRCVEN := nPreco
					DA1->(MsUnlock())

					//Deleta Os registros
					nT := 0
					For nT:=1 To Len(aTabDel)
						DA1->(DbGoTo(aTabDel[nT]))
						Reclock("DA1",.F.)
							DA1->(DbDelete())
						DA1->(MsUnlock())
					Next nT

					(cAliasDA1)->(DbSkip())
				EndDo

				(cAliasDA1)->(DbCloseArea())

			EndIf

		EndIf

	Next nX

	ApMsgInfo("Cópia efetuada com sucesso")

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} AN011
Atualização de Tabela de Preço
@author felipe.caiado
@since 13/03/2019
@version undefined
@type function
/*/
//-------------------------------------------------------------------
Static Function AN011()

	Local oModel     	:= FWModelActive()
	Local oView			:= FwViewActive()
	Local oModelSB1  	:= oModel:GetModel( 'SB1DETAIL' )
	Local oModelALT  	:= oModel:GetModel( 'ALTDETAIL' )
	Local oModelFIL  	:= oModel:GetModel( 'FILMASTER' )
	Local nT			:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nA			:= 0
	Local nB			:= 0
	Local cAliasDA1		:= GetNextAlias()
	Local cAliasITE		:= GetNextAlias()
	Local cCodDA0		:= Alltrim(SuperGetMv("AN_TABPRC",.F.,"100"))
	Local cMsg			:= ""
	Local lProd			:= .F.
	Local lAtuLetra		:= .F.
	Local lAtuDesc		:= .F.
	Local lAtuPRep		:= .F.
	Local aRet as array
	Local aPerg as array

	aRet 	:= {}
	aPerg	:= {}

	aAdd( aPerg ,{1,Alltrim("Data"),CtoD("  /  /  "),"",".T.","","",40,.F.})
	aAdd( aPerg ,{1,Alltrim("Tabela"),Space(1),"@!",".T.","","",10,.F.})
	aAdd( aPerg ,{1,Alltrim("Filial"),Space(06),"@!",".T.","SM0","",30,.F.})

	If !ParamBox(aPerg ,"Cópia de Tabela",@aRet)
		Return()
	EndIf

	//Verifica se está vazio os parâmetros
	If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03)
		ApMsgInfo("Favor preencher todos os parâmetros")
		Return()
	EndIf

	cMsg := "Confirma a Atualização da tabela de preço?" + CRLF

	cMsg += CRLF
	cMsg += "---------------------------------" + CRLF
	cMsg += "FILTRO UTILIZADO:" + CRLF
	cMsg += "---------------------------------" + CRLF
	cMsg += CRLF
	cMsg += "MARCA: " + oModelFIL:GetValue("XX_MARCA") + CRLF
	cMsg += "PRODUTO: " + oModelFIL:GetValue("XX_PRODUT") + CRLF
	cMsg += "LINHA: " + oModelFIL:GetValue("XX_LINHA") + CRLF
	cMsg += "CURVA: " + oModelFIL:GetValue("XX_CURVA")

	If !ApMsgNoYes(cMsg) //Se for não a resposta pergunta se quer fazer por produto

		lProd := ApMsgNoYes("Deseja fazer a cópia do produto " + Alltrim(cCodigo) + "-" + Alltrim(cDescri))

		If !lProd

			Return()

		EndIf
	EndIf

	For nX := 1 to oModelSB1:Length()

		oModelSB1:GoLine(nX)

		If lProd
			If Alltrim(cCodigo) <> Alltrim(oModelSB1:GetValue("B1_COD"))
				Loop
			EndIf
		EndIf

		lCriaReg := .T.

		cTabProc 	:= ""
		aTabSeq		:= {}
		aTabDel		:= {}

		lAtualiz	:= .F.

		DbSelectArea("DA1")
		DA1->(DbOrderNickName("DA1SEQ"))//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_XTABSQ
		If DA1->(DbSeek(Alltrim(MV_PAR03)+cCodDA0+oModelSB1:GetValue("B1_COD")))

			While !DA1->(Eof()) .And. Alltrim(MV_PAR03)+cCodDA0+oModelSB1:GetValue("B1_COD") == DA1->DA1_FILIAL+DA1->DA1_CODTAB+DA1->DA1_CODPRO

				//Verifica se é menor que a tabela 1
				If DA1->DA1_DATVIG > MV_PAR01

					DA1->(DbSkip())
					Loop

				ElseIf DA1->DA1_DATVIG == MV_PAR01

					lCriaReg := .F.

					Reclock("DA1",.F.)
					DA1->DA1_XFATOR := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[3]
					DA1->DA1_XMARGE := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[1]
					DA1->DA1_XPRCBR := ( DA1->DA1_XPRCRE + (DA1->DA1_XPRCRE * (DA1->DA1_XMARGE/100)) + (DA1->DA1_XPRCRE * (DA1->DA1_XFATOR/100)) )
					nPrcVen := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[4]
					nPreco := nPrcVen - (nPrcVen *(DA1->DA1_XDESCV/100))
					DA1->DA1_XPRCLI := nPreco
					DA1->DA1_PRCVEN := nPreco
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
				For nT:=1 To Len(aTabSeq)
					DA1->(DbGoTo(aTabSeq[nT][1]))
					Reclock("DA1",.F.)
						DA1->DA1_XTABSQ := aTabSeq[nT][2]
					DA1->(MsUnlock())
				Next nT

				cTabProx := Soma1(cTabProc)

				//Localiza a vigencia da tabela 1
				BeginSQL alias cAliasDA1
				SELECT
					R_E_C_N_O_ RECNUM
				FROM
					%table:DA1% DA1
				WHERE
					DA1_FILIAL = %exp:MV_PAR03%
					AND DA1_CODPRO = %exp:oModelSB1:GetValue("B1_COD")%
					AND DA1_CODTAB = %exp:cCodDA0%
					AND DA1_XTABSQ = %exp:cTabProx%
					AND DA1.%notDel%
				EndSql

				//Estrutura da DA1
				aStruct := DA1->(DbStruct())

				aReg := {}

				nA := 0

				//Localiza o ultimo item da tabela
				BeginSQL alias cAliasITE
				SELECT
					MAX(DA1_ITEM) DA1_ITEM
				FROM
					%table:DA1% DA1
				WHERE
					DA1_FILIAL = %exp:MV_PAR03%
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

					Next na

					nB := 0

					Reclock("DA1",.T.)

					For nB:=1 To Len(aReg)

						If Alltrim(aReg[nB][1]) == "DA1_XTABSQ"
							DA1->DA1_XTABSQ := cTabProc
							Loop
						EndIf

						If Alltrim(aReg[nB][1]) == "DA1_DATVIG"
							DA1->DA1_DATVIG := MV_PAR01
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
					DA1->DA1_XFATOR := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[3]
					DA1->DA1_XMARGE := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[1]
					DA1->DA1_XPRCBR := ( DA1->DA1_XPRCRE + (DA1->DA1_XPRCRE * (DA1->DA1_XMARGE/100)) + (DA1->DA1_XPRCRE * (DA1->DA1_XFATOR/100)) )
					nPrcVen := u_CalcPrcV(Upper(Alltrim(DA1->DA1_XLETRA)), cCodigo, DA1->DA1_FILIAL, DA1->DA1_XPRCRE)[4]
					nPreco := nPrcVen - (nPrcVen *(DA1->DA1_XDESCV/100))
					DA1->DA1_XPRCLI := nPreco
					DA1->DA1_PRCVEN := nPreco
					DA1->(MsUnlock())

					//Deleta Os registros
					nT := 0
					For nT:=1 To Len(aTabDel)
						DA1->(DbGoTo(aTabDel[nT]))
						Reclock("DA1",.F.)
							DA1->(DbDelete())
						DA1->(MsUnlock())
					Next nT

					(cAliasDA1)->(DbSkip())
				EndDo

				(cAliasDA1)->(DbCloseArea())

			EndIf

		EndIf

	Next nX

	ApMsgInfo("Recálculo efetuada com sucesso")

Return()