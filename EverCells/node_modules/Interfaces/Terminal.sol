pragma ton-solidity >=0.35.0;

// Это интерфейс для вызова функций дебота
interface ITerminal {

	function input(uint32 answerId, string prompt, bool multiline) external returns (string value);
	function print(uint32 answerId, string message) external;
	function printf(uint32 answerId, string fmt, TvmCell fargs) external;
}

library Terminal {

	// Это ID интерфейса дебота
	// Он обязательно должен быть прописан
	// менять его не надо! Это стандартные инетерфейсы
	// больше интерфейсов можно найти тут https://github.com/tonlabs/DeBot-IS-consortium
	uint256 constant ID = 0x8796536366ee21852db56dccb60bc564598b618c865fc50c8b1ab740bba128e3;
	int8 constant DEBOT_WC = -31;

	// Печатает сообщение пользователю и возвращает строку, введенную пользователем
	// answerId - идентификатор функции обратного вызова результата
	// prompt - строка, выводимая пользователю и описывающая, что нужно ввести
	// multiline - разрешить многострочный ввод текста
	// return Строка utf8, введенная пользователем (смотри объявление функции в ITerminal) 
	function input(uint32 answerId, string prompt, bool multiline) public pure {
		// Генерация адреса по которому расположена библиотека Terminal?
		address addr = address.makeAddrStd(DEBOT_WC, ID);
		// Сгенерированный адрес библиотеки приводится к типу ITerminal
		// То есть мы получаем адрес, где реально лежит этот Terminal в блокчейне
		// и вызываем на нём функцию input, используя предоставленный интерфейс?
		// А где тогда посмотреть сам этот контракт, который всё реализует?
		ITerminal(addr).input(answerId, prompt, multiline);
	}

	// показывает пользователю строковое сообщение
	// answerId - идентификатор функции обратного вызова, может быть равен 0.
	// message - строка utf8 как массив байтов
	// return void
	function print(uint32 answerId, string message) public pure {
		address addr = address.makeAddrStd(DEBOT_WC, ID);
		ITerminal(addr).print(answerId, message);
	}

	// показывает пользователю форматированное строковое сообщение
	// answerId - идентификатор функции обратного вызова результата
	// fmt - строка utf8 в виде массива байтов, которая должна быть выведена пользователю
	// fargs - ячейка с сериализованными аргументами формата, которые должны быть вставлены в строку `format`
	// вместо спецификаторов формата (подпоследовательности между скобками `{}`).
	// подробнее по форматированному выводу здесь https://github.com/tonlabs/DeBot-IS-consortium/tree/main/Terminal
	// return Строка utf8, введенная пользователем (смотри объявление функции в ITerminal) 
	function printf(uint32 answerId, string fmt, TvmCell fargs) public pure {
		address addr = address.makeAddrStd(DEBOT_WC, ID);
		ITerminal(addr).printf(answerId, fmt, fargs);
	}

}