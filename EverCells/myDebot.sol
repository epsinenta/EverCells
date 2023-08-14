pragma ton-solidity >=0.57.0;
pragma AbiHeader pubkey;
pragma AbiHeader expire;

import "Libraries/Debot.sol";
import "Interfaces/Terminal.sol";
import "Contract/Evercell.sol";

contract myDebot is Debot {
	address public evercell;

	// в качестве аргумента конструктор принимает адрес контракта Questionnaire
	constructor(address _evercell) public {
		require(tvm.pubkey() != 0, 101);
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		evercell = _evercell;
	}

	// Добавьте описание вашего дебота
	function getDebotInfo()
		public
		view
		override
		functionID(0xDEB)
		returns (
			string name,
			string version,
			string publisher,
			string caption,
			string author,
			address support,
			string hello,
			string language,
			string dabi,
			bytes icon
		)
	{
		name = "CellsDebot";
		version = "0.0.1";
		publisher = "SHP";
		caption = "test";
		author = "xXxPanamAxXx, kotuk, and a little bit quswadress";
		support = address.makeAddrStd(0, 0x0);
		hello = "Dont touch";
		language = "en";
		dabi = m_debotAbi.get();
		icon = "";
	}

	function getRequiredInterfaces()
		public
		view
		override
		returns (uint256[] interfaces)
	{
		return [Terminal.ID];
	}

	// здесь начинается выполнение дебота
	function start() public override {
		// функция Terminal.input() выводит строку и считывает введённую строку
		// далее вызывается следующая функция дебота, куда передаётся считанная строка
		call = tvm.functionId(CreateCell);
		Terminal.print(0, "There should be a menu here, but there isn't."
						  "Be glad that it works at all without errors and crashes. "
						  "Someone spent a night of his life to make it work at least that way.");
		Terminal.input(tvm.functionId(setContent), "Create cell!", false);
	}

	string private content;
	uint256 private id;
	string private password;
	string private newPassword;
	uint32 private call;
	
	function setNewPassword(string value) public {
		newPassword = value;
		ChangePassword();
	}
	function setPassword(string value) public {
		password = value;
		if (call == tvm.functionId(CreateCell)) {
			CreateCell();
		}
		if (call == tvm.functionId(ViewCell)) {
			ViewCell();
		}
		if (call == tvm.functionId(ChangeContent)) {
			Terminal.input(tvm.functionId(setContent), "Input content", false);
		}
		if (call == tvm.functionId(ChangePassword)) {
			Terminal.input(tvm.functionId(setNewPassword), "Input new password", false);
		}
		if (call == tvm.functionId(DeleteCell)) {
			DeleteCell();
		}
	}
	function setContent(string value) public {
		content = value;
		if (call == tvm.functionId(CreateCell) || call == tvm.functionId(ViewCell)) {
			Terminal.input(tvm.functionId(setPassword), "Input password", false);
		}
		if (call == tvm.functionId(ChangeContent)) {
			ChangeContent();
		}
	}
	function setId(string value) public {
		optional(int) optional_id = stoi(value);
		if (!optional_id.hasValue() || optional_id.get() < 0) {
			Terminal.input(tvm.functionId(setId), "Invalid id.", false);
			return;
		}
		id = uint256(optional_id.get());
		Terminal.input(tvm.functionId(setPassword), "Input password", false);
	}

	function CreateCell() public {
		call = tvm.functionId(ViewCell);
		IEverCell(evercell).createCell{
			sign: true,
			pubkey: 0,
			time: 0,
			expire: 0,
			abiVer: 50,
			callbackId: tvm.functionId(setId),
			onErrorId: tvm.functionId(onError)
		}(content, password).extMsg;
	}

	function ViewCell() public {
		call = tvm.functionId(ChangeContent);
		IEverCell(evercell).viewCell{
			sign: false,
			pubkey: 0,
			time: 0,
			expire: 0,
			abiVer: 50,
			callbackId: tvm.functionId(setId),
			onErrorId: tvm.functionId(onError)
		}(id, password).extMsg;
	}

	function ChangeContent() public {
		call = tvm.functionId(ChangePassword);
		IEverCell(evercell).changeContent{
			sign: true,
			pubkey: 0,
			time: 0,
			expire: 0,
			abiVer: 50,
			callbackId: tvm.functionId(setId),
			onErrorId: tvm.functionId(onError)
		}(id, password, content).extMsg;
	}

	function ChangePassword() public {
		call = tvm.functionId(DeleteCell);
		IEverCell(evercell).changePassword{
			sign: true,
			pubkey: 0,
			time: 0,
			expire: 0,
			abiVer: 50,
			callbackId: tvm.functionId(setId),
			onErrorId: tvm.functionId(onError)
		}(id, password, newPassword).extMsg;
	}

	function DeleteCell() public {
		call = tvm.functionId(GetResult);
		IEverCell(evercell).deleteCell{
			sign: true,
			pubkey: 0,
			time: 0,
			expire: 0,
			abiVer: 50,
			callbackId: tvm.functionId(GetResult),
			onErrorId: tvm.functionId(onError)
		}(id, password).extMsg;
	}

	function GetResult(string value) public pure {
		// TODO
		Terminal.print(0, format("[TODO] Your content: {}", value));
	}

	function onError(uint32 sdkError, uint32 exitCode) public pure {
		Terminal.print(
			0,
			format(
				"Operation failed. sdkError {}, exitCode {}",
				sdkError,
				exitCode
			)
		);
	}
}
