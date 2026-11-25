export type TestExpect = {
	Success: boolean,
	Err: any,
	Value: any,
	Flip: boolean,
	Not: (self: TestExpect) -> TestExpect,
	ToBe: (self: TestExpect, value: any) -> (),
	ToNeverBe: (self: TestExpect, value: any) -> (),
	ToBeNaN: (self: TestExpect, value: any) -> (),
	ToBeNil: (self: TestExpect) -> (),
	ToBeOk: (self: TestExpect) -> (),
	ToBeTrue: (self: TestExpect) -> (),
	ToBeFalse: (self: TestExpect) -> (),
	ToBeTruthy: (self: TestExpect) -> (),
	ToBeFalsy: (self: TestExpect) -> (),
	ToThrow: (self: TestExpect, err: any?) -> (),
	ToHaveLength: (self: TestExpect, length: number) -> (),
	ToHaveProperty: (self: TestExpect, property: string) -> (),
	ToBeGreaterThan: (self: TestExpect, value: number) -> (),
	ToBeGreaterThanOrEqual: (self: TestExpect, value: number) -> (),
	ToBeLessThan: (self: TestExpect, value: number) -> (),
	ToBeLessThanOrEqual: (self: TestExpect, value: number) -> (),
	ToContain: (self: TestExpect, value: any) -> (),
	ToBeNear: (self: TestExpect, value: number, epsilon: number) -> (),
	ToBeA: (self: TestExpect, typeOf: string) -> (),
}

local function RunAll(funcs)
	for i,func in funcs do
		func()
	end
end

local TestExpect = {}
TestExpect.__index = TestExpect

function TestExpect:ToBe(value: any)
	local condition = self.Value == value
	
	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "!=" else "=="} {value}`, 0)
	end
end

function TestExpect:ToNeverBe(value: any)
	local condition = self.Value ~= value

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} != {value}`, 0)
	end
end

function TestExpect:ToBeFalse()
	local condition = type(self.Value) == "boolean" and self.Value == false

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "!=" else "=="} false`, 0)
	end
end

function TestExpect:ToBeTrue()
	local condition = false
	
	if type(self.Value) == "boolean" then
		condition = self.Value == true
	end
	
	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "!=" else "=="} true`, 0)
	end
end

function TestExpect:ToBeNil()
	local condition = self.Value == nil
	
	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "!=" else "=="} nil`, 0)
	end
end

function TestExpect:ToBeOk()
	local condition = self.Value ~= nil
	
	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "is not" else "is"} ok`, 0)
	end
end

function TestExpect:ToBeNaN()
	local condition = self.Value ~= self.Value
	
	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "!=" else "=="} NaN`, 0)
	end
end

function TestExpect:ToThrow(err: any?)
	local condition: boolean
	
	if err ~= nil then
		condition = (not self.Success) and self.Err == err
	else
		condition = not self.Success
	end

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{if self.Flip then "expected to not throw" else "expected to throw"}`, 0)
	end
end

function TestExpect:ToBeTruthy()
	local condition = not not self.Value

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "not truthy" else "truthy"}`, 0)
	end
end

function TestExpect:ToBeFalsy()
	local condition = not self.Value

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "not falsy" else "falsy"}`, 0)
	end
end

function TestExpect:ToHaveLength(length: number)
	local t = type(self.Value)
	local validType = t == "string" or t == "table"
	local condition = validType and #self.Value == length

	if self.Flip and validType then
		condition = not condition
	end

	if not condition then
		if validType then
			error(`{t} length ({#self.Value}) {if self.Flip then "!=" else "=="} {length}`, 0)
		else
			error(`invalid type "{t}" (expected table or string)`, 0)
		end
	end
end

function TestExpect:ToHaveProperty(property: string)
	local t = typeof(self.Value)
	local validType = t == "table"
	local condition = validType and self.Value[property] ~= nil

	if self.Flip and validType then
		condition = not condition
	end

	if not condition then
		if validType then
			error(`table {if self.Flip then "does not contain" else "contains"} property "{property}"`, 0)
		else
			error(`invalid type "{t}" (expected table)`, 0)
		end
	end
end

function TestExpect:ToBeGreaterThan(value: number)
	local condition = self.Value > value

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "<=" else ">"} {value}`, 0)
	end
end

function TestExpect:ToBeGreaterThanOrEqual(value: number)
	local condition = self.Value >= value

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "<" else ">="} {value}`, 0)
	end
end

function TestExpect:ToBeLessThan(value: number)
	local condition = self.Value < value

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then ">=" else "<"} {value}`, 0)
	end
end

function TestExpect:ToBeLessThanOrEqual(value: number)
	local condition = self.Value <= value

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then ">" else "<="} {value}`, 0)
	end
end

function TestExpect:ToContain(value: any)
	local t = type(self.Value)
	local valid = t == "table" or t == "string"
	if t == "string" then
		valid = type(value) == "string"
	end

	local condition = false

	if valid then
		if t == "table" then
			condition = table.find(self.Value, value) ~= nil
		else
			condition = string.find(self.Value, value) ~= nil
		end
	end

	if self.Flip and valid then
		condition = not condition
	end

	if not condition then
		if valid then
			error(`"{value}" {if self.Flip then "not in" else "in"} {t}`, 0)
		else
			error(`invalid type "{t}" (expected table or string)`, 0)
		end
	end
end

function TestExpect:ToBeA(typeOf: string)
	local condition = typeof(self.Value) == typeOf

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`"{typeof(self.Value)}" {if self.Flip then "!=" else "=="} "{typeOf}"`, 0)
	end
end

function TestExpect:ToBeNear(value: number, epsilon: number)
	local condition = math.abs(self.Value - value) < epsilon

	if self.Flip then
		condition = not condition
	end

	if not condition then
		error(`{self.Value} {if self.Flip then "is not near" else "is near"} {value}`, 0)
	end
end

function TestExpect:Not()
	self.Flip = not self.Flip return self
end

------------------------------------------------------------------------------------------------------------

export type TestContext = {
	It: (self: TestContext, name: string, func: () -> ()) -> (),
	Describe: (self: TestContext, name: string, func: () -> ()) -> (),
	Expect: (self: TestContext, value: any) -> TestExpect,
	BeforeAll: (self: TestContext, func: () -> ()) -> (),
	AfterAll: (self: TestContext, func: () -> ()) -> (),
	BeforeEach: (self: TestContext, func: () -> ()) -> (),
	AfterEach: (self: TestContext, func: () -> ()) -> (),
}

type TestContextGroup = {
	Name: string,
	Items: { any },
	AnyFail: boolean,
	AfterAllFns: { () -> () },
	BeforeEachFns: { () -> () },
	AfterEachFns: { () -> () },
}

local function CreateGroup(name: string): TestContextGroup
	return {
		Name = name,
		Items = {},
		AnyFail = false,
		AfterAllFuncs = {},
		BeforeEachFuncs = {},
		AfterEachFuncs = {},
	}
end

local TestContext = {}
TestContext.__index = TestContext

function TestContext.new(root: string): TestContext
	local testContext = setmetatable({
		TotalTests = 0,
		TotalFails = 0,
		Group = CreateGroup(root),
	}, TestContext) :: any
	testContext.Current = testContext.Group
	return testContext
end

function TestContext:It(name: string, func: () -> ())
	RunAll(self.Current.BeforeEachFuncs)
	local lastTime = os.clock()
	local success,err=pcall(func)
	local nowTime = os.clock()
	self.Current.Items[name] = {
		Success = success,
		Err = err,
		Time = nowTime - lastTime,
	}
	self.TotalTests += 1
	if not success then
		self.TotalFails += 1
		self.Current.AnyFail = true
	end
	RunAll(self.Current.AfterEachFuncs)
end

function TestContext:Describe(name: string, func: () -> ())
	local parentGroup = self.Current
	local group = CreateGroup(name)
	self.Current = group
	parentGroup.Items[name] = group
	RunAll(parentGroup.BeforeEachFuncs)
	func()
	self.Current = parentGroup
	if group.AnyFail then
		parentGroup.AnyFail = true
	end
	RunAll(group.AfterAllFuncs)
	RunAll(parentGroup.AfterEachFuncs)
end

function TestContext:Expect(value: any): TestExpect
	local resolvedValue = value
	local success, err = true, nil
	if type(value) == "function" then
		success, err = pcall(value)
		resolvedValue = if success then err else nil
	end
	return setmetatable({ Value = resolvedValue, Success = success, Err = err, Flip = false }, TestExpect) :: any
end

function TestContext:BeforeAll(func: () -> ())
	func()
end

function TestContext:AfterAll(func: () -> ())
	table.insert(self.Current.AfterAllFuncs, func)
end

function TestContext:BeforeEach(func: () -> ())
	table.insert(self.Current.BeforeEachFuncs, func)
end

function TestContext:AfterEach(func: () -> ())
	table.insert(self.Current.AfterEachFuncs, func)
end

------------------------------------------------------------------------------------------------------------

export type Test={
	Run: (self:Tests, ancestors: { Instance }) -> ()
}

local Test = {}

function Test.Run(self: Test, ancestors: { Instance })
	local tests: { [string]: () -> () } = {}

	for k,ancestor in ancestors do
		for k, child in ancestor:GetDescendants() do
			if child:IsA("ModuleScript") and string.match(child.Name, "%.test$") ~= nil then
				local name = (string.match(child.Name, "(.+)%.test$")) or child.Name
				if name == "init" then
					name = child.Parent.Name
				end
				local func = require(child)
				tests[name] = func
			end
		end
	end

	local results: { TestContext } = {}
	local allPass = true

	local totalTests = 0
	local totalFails = 0
	local totalSuccesses = 0

	for name, func in tests do
		if type(func) ~= "function" then continue end
		local context = TestContext.new(name)
		func(context)
		--local success, err = pcall(func, context)
		--if not success then
		--	error(`Test runner failed: {err}`)
		--end
		table.insert(results, context)
		if context.Group.AnyFail then
			allPass = false
		end
		context.Current = nil
		totalTests += context.TotalTests
		totalFails += context.TotalFails
	end
	totalSuccesses = totalTests - totalFails

	-- Build results:
	local outputs = { "\n Test Results" }
	
	local function Input(str: string)
		table.insert(outputs, str)
	end
	
	Input("")
	Input(`AllPass: {allPass}`)
	Input("")
	Input("---------")
	Input(`{totalTests} Total`)
	Input(`{totalSuccesses} Passed`)
	Input(`{totalFails} Failed`)
	Input("---------")
	Input("")
	
	local function Output(s, group, level)
		Input(`{string.rep(s, level)}[{if group.AnyFail then "X" else "✓"}] {group.Name}`)
		for name, item in group.Items do
			if item.Items then
				Output(s, item, level + 1)
			else
				local t=item.Time or 0
				local ts=string.format("%.5f",t).." ms"
				Input(
					`{string.rep(s, level + 1)}[{if not item.Success then "X" else "✓"}] {name} {ts} {if not item.Success
						then `\n{string.rep(s, level + 2)}failed assertion: {item.Err}`
						else ""}`
				)
			end
		end
		return s
	end

	local s = "    "
	for _, ctx in results do
		s=Output(s, ctx.Group, 0)
	end
	
	Input("")
	
	local text = table.concat(outputs, "\n\n")
	return text
end

return Test
