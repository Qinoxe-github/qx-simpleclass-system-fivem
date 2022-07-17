--- Created by Absolute.
--- DateTime: 31/01/2022 21:46

Repositories = {};
QX.export("Repository", function(cls)
    ---@class Repository : QX.Object
    local Repository = cls;
    function Repository:constructor(schema)

        self.schema = schema;
        self.schema.table = string.lower(self.schema.table);
        self.schema.insertFields = self:generateInsertFields();
        self.schema.insertFieldsParams = self:generateInsertFieldsParams();
        self.schema.updateFields = self:generateUpdateFields(self.schema.columns);
        self:createTable();
        if(QX.Config.orm.debug) then
            Console:debug("^3Important Entity need to have a primary key named id to be serialized in database^7");
        end
        self.schema.class = self.schema.class and QX.import(self.schema.class) or nil;
        Repositories[schema.table] = self;
    end

    function Repository:newInstance(...)
        if self.schema.class then
            local obj = self.schema.class:new(...);
            obj.id = QX.uuid();
            return obj;
        end
    end

    function Repository:createTable()
        local sql = "CREATE TABLE IF NOT EXISTS `" ..
                self.schema.table ..
                "` (id varchar(36) PRIMARY KEY,";
        for k, v in pairs(self.schema.columns) do
            sql = sql .. k .. " " .. v.type .. " " .. (v.isPrimary and " PRIMARY KEY" or "") .. "\n,";
        end
        sql = sql:sub(1, -2);
        sql = sql .. ")";

        self.schema.columns.id = { type = "varchar(36)" };

        if QX.Config.orm.enabled then
            if QX.Config.orm.debug then
                Console:debug(sql);
            end
            MySQL.query(sql, {}, function()

            end);
        end
    end

    function Repository:generateInsertFieldsParams()
        local insert = "";
        for k, v in pairs(self.schema.columns) do
            insert = insert .. k .. ",";
        end
        return insert:sub(1, -2);
    end

    function Repository:generateInsertFields()
        local insert = "";
        for k, v in pairs(self.schema.columns) do
            insert = insert .. "@" .. k .. ",";
        end
        return insert:sub(1, -2);
    end

    function Repository:generateUpdateFields()
        local update = "";
        for k, v in pairs(self.schema.columns) do
            update = update .. k .. " = @" .. k .. ",";
        end
        return update:sub(1, -2);
    end

    function Repository:getAttributesInsert()
        local fields = o.fields.data;
    end

    function Repository:generateWhere(sql, where)
        if self:getWhereLength(where) > 0 then
            sql = sql .. " WHERE ";
            for col, val in pairs(where) do
                if self.schema.columns[col] ~= nil then
                    if type(val) == "table" then
                        sql = sql .. col .. " " .. (val.operator == nil and " = " or val.operator) .. " :" .. col .. " AND ";
                    else
                        sql = sql .. col .. " = " .. ":" .. col .. " AND ";
                    end

                else
                    Console:warn("Error column " .. col .. " not found");
                    return "";
                end

            end
            return sql:sub(1, -5);
        end
        return sql;
    end

    function Repository:getWhereLength(where)
        local count = 0
        for _, data in pairs(where) do
            count = count + 1;
        end
        return count;
    end

    function Repository:generateValues(where)
        local values = {};
        for k, v in pairs(where) do

            if self.schema.columns[k] ~= nil then
                if type(v) == "table" and v.operator then
                    if v.operator:upper() == "LIKE" then
                        values[k] = self:convertData("%" .. v.value .. "%");
                    else
                        values[k] = self:convertData(v.value);
                    end
                elseif type(v) == "table" and v.operator == nil then
                    values[k] = self:convertData(v);
                else
                    values[k] = v;
                end
            end


        end
        return values;
    end

    function Repository:convertData(value)
        if value.class == "List" or value.class == "Map" then
            value = json.encode(value.data);
        elseif type(value) == "table" then
            value = json.encode(self:removeFunct(value));
        end

        return value;
    end

    function Repository:removeFunct(value)
        tab = {}
        for i, v in pairs(value) do
            if type(v) ~= "function" then
                tab[i] = v;
            end
        end
        return tab;
    end

    function Repository:generateJoin(sql,ignoreJoins)
        if(ignoreJoins) then
            return sql;
        end
        if self.schema.joins then
            for i, v in pairs(self.schema.joins) do
                sql = sql .. " JOIN " .. v.join .. " ON " .. self.schema.table .. "." .. i .. " = " .. v.join .. "." .. v.joinColumn;
            end
        end
        return sql;
    end

    function Repository:create(entity, cb)

        local await = cb == nil;

        local sql = "INSERT INTO " .. self.schema.table .. " (" .. self:generateInsertFieldsParams() .. ") VALUES (" .. self:generateInsertFields() .. ")";
        if QX.Config.orm.debug then
            Console:debug(sql);
        end
        if QX.Config.orm.enabled then
            if await then
                MySQL.insert.await(sql, self:generateValues(entity), cb);
            else
                MySQL.insert(sql, self:generateValues(entity), cb);
            end

        end
    end

    function Repository:update(entity, cb)

        local await = cb == nil;

        local sql = "UPDATE " .. self.schema.table .. " SET " .. self:generateUpdateFields(entity);
        sql = self:generateWhere(sql, { id = (entity.id and entity.id or "") });
        if QX.Config.orm.debug then
            Console:debug(sql);
        end
        if QX.Config.orm.enabled then
            if await then
                MySQL.update.await(sql, self:generateValues(entity));
            else
                MySQL.update(sql, self:generateValues(entity), cb);
            end

        end
    end

    function Repository:createOrUpdate(entity, cb)
        local exist = self:exist({ id = entity.id });
        if exist then
            self:update(entity, cb);
        else
            self:create(entity, cb);
        end
    end

    function Repository:delete(entity, cb)
        local sql = "DELETE FROM " .. self.schema.table;
        sql = self:generateWhere(sql, { id = entity.id });

        local await = cb == nil;

        if QX.Config.orm.debug then
            Console:debug(sql);
        end
        if QX.Config.orm.enabled then
            if await then
                MySQL.update.await(sql, { id = entity.id });
            else
                MySQL.update(sql, { id = entity.id }, cb);
            end

        end
    end

    function Repository:deleteFilter(where, cb, await)
        local sql = "DELETE FROM " .. self.schema.table;
        sql = self:generateWhere(sql, where);
        if QX.Config.orm.debug then
            Console:debug(sql);
        end
        if QX.Config.orm.enabled then
            if await then
                MySQL.update.await(sql, self:generateValues(where));
            else
                MySQL.update(sql, self:generateValues(where), cb);
            end

        end
    end

    function Repository:deleteAll(cb, await)
        local sql = "DELETE FROM " .. self.schema.table;
        if QX.Config.orm.debug then
            Console:debug(sql);
        end
        if QX.Config.orm.enabled then
            if await then
                MySQL.update.await(sql, {});
            else
                MySQL.update(sql, {}, cb);
            end
        end
    end

    function Repository:convertToObjects(objects)
        if type(objects) == "table" and #objects > 0 then
            for k, v in pairs(objects) do
                self:convertToObject(v);
            end
        elseif objects ~= nil then
            self:convertToObject(objects);
        end
        return objects;
    end

    function Repository:convertToObject(object)
        for k, v in pairs(object) do
            if self.schema.columns[k] ~= nil and self.schema.columns[k].output then
                local data = json.decode(v);

                if self.schema.columns[k].output == "List" then
                    object[k] = QX.assign("List", data);
                elseif self.schema.columns[k].output == "Map" then
                    object[k] = QX.assign("Map", data);
                else
                    object[k] = data
                end
            end
        end
    end

    function Repository:read(id, cb,ignoreJoin)

        local sql = "SELECT * FROM " .. self.schema.table;
        sql = self:generateJoin(sql,ignoreJoin);

        sql = self:generateWhere(sql, { id = id and id or "" });

        if QX.Config.orm.enabled then
            if QX.Config.orm.debug then
                Console:debug(sql);
            end

            MySQL.query(sql, self:generateValues(where), function(result)
                cb(self:convertToObjects(result));
            end);
        end
    end

    function Repository:readAll(cb,ignoreJoin)
        local sql = "SELECT * FROM " .. self.schema.table;
        sql = self:generateJoin(sql,ignoreJoin);

        local await = cb == nil;

        if QX.Config.orm.enabled then
            if QX.Config.orm.debug then
                Console:debug(sql);
            end
            if await then
                local query = MySQL.query.await(sql, {})
                return self:convertToObjects(query);
            end
            MySQL.query(sql, {}, function(result)
                if cb then
                    cb(self:convertToObjects(result));
                else
                    Console:warn("No callback set (^1Repository:readAll()^3)")
                end
            end);
        end
    end

    function Repository:exist(where,cb,ignoreJoin)
        local sql = "SELECT * FROM " .. self.schema.table;
        sql = self:generateJoin(sql,ignoreJoin);
        sql = self:generateWhere(sql, where);
        local await = cb == nil;
        if not await then
            MySQL.query(sql .. " LIMIT 1", self:generateValues(where), function(result)
                if cb then
                    cb(#result > 0)
                end
            end);
        else
            local result = MySQL.query.await(sql .. " LIMIT 1", self:generateValues(where))
            return (#result > 0)
        end

    end

    function Repository:search(where, cb,ignoreJoin)
        local sql = "SELECT * FROM " .. self.schema.table;

        sql = self:generateJoin(sql,ignoreJoin);
        local me = self;

        local await = cb == nil;

        if where ~= nil then
            sql = self:generateWhere(sql, where);

            if QX.Config.orm.enabled then
                if QX.Config.orm.debug then
                    Console:debug(sql);
                end

                if not await then
                    MySQL.query(sql, self:generateValues(where), function(result)
                        if cb then
                            cb(self:convertToObjects(result))
                        end
                    end);
                else
                    local result = MySQL.query.await(sql, self:generateValues(where))
                    return self:convertToObjects(result)
                end
            end
        else

            if QX.Config.orm.enabled then
                if QX.Config.orm.debug then
                    Console:debug(sql);
                end
                if not await then
                    MySQL.query(sql, {}, function(result)
                        if cb then
                            cb(self:convertToObjects(result))
                        end
                    end);
                else
                    local result = MySQL.query.await(sql, {})
                    return self:convertToObjects(result)
                end
            end
        end
    end

    function Repository:searchFirst(where, cb,ignoreJoin)
        local sql = "SELECT * FROM " .. self.schema.table;

        local await = cb == nil;

        sql = self:generateJoin(sql,ignoreJoin);
        local me = self;
        if where ~= nil then
            sql = self:generateWhere(sql, where);

            if QX.Config.orm.enabled then
                if QX.Config.orm.debug then
                    Console:debug(sql);
                end
                if not await then
                    MySQL.query(sql .. " LIMIT 1", self:generateValues(where), function(result)
                        if cb then
                            cb((#result > 0 and self:convertToObjects(result[1])) or nil)
                        end
                    end);
                else
                    local result = MySQL.query.await(sql .. " LIMIT 1", self:generateValues(where))
                    return ((#result > 0 and self:convertToObjects(result[1])) or nil)
                end

            end
        else

            if QX.Config.orm.enabled then
                if QX.Config.orm.debug then
                    Console:debug(sql);
                end

                if not await then
                    MySQL.query(sql .. " LIMIT 1", {}, function(result)
                        if cb then
                            cb((#result > 0 and self:convertToObjects(result[1])) or nil)
                        end
                    end);
                else
                    local result = MySQL.query.await(sql .. " LIMIT 1", {})
                    return ((#result > 0 and self:convertToObjects(result[1])) or nil)
                end
            end
        end
    end

    function Repository:count(where, cb,ignoreJoin)
        local sql = "SELECT COUNT(*) as count FROM " .. self.schema.table;

        sql = self:generateJoin(sql,ignoreJoin);

        local await = cb == nil;

        if where ~= nil then
            sql = self:generateWhere(sql, where);
            if QX.Config.orm.enabled then
                if QX.Config.orm.debug then
                    Console:debug(sql);
                end

                if not await then
                    MySQL.query(sql, self:generateValues(where), function(result)
                        cb(result[1].count)
                    end);
                else
                    local result = MySQL.query.await(sql, self:generateValues(where))
                    return (result[1].count)
                end
            end
        else
            if QX.Config.orm.enabled then
                if QX.Config.orm.debug then
                    Console:debug(sql);
                end
                if not await then
                    MySQL.query(sql, {}, function(result)
                        cb(result[1].count)
                    end);
                else
                    local result = MySQL.query.await(sql, {})
                    return (result[1].count)
                end
            end
        end
    end

    function Repository:execute(sql, params, cb)
        MySQL.update(sql, params, cb);
    end

    function Repository:fetchAll(sql, params, cb)
        MySQL.query(sql, params, cb);
    end

    function Repository:initData()

    end

    return Repository;
end)


