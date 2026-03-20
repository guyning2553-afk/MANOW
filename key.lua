local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- [[ ตั้งค่าส่วนตัวของคุณ ]] --

local MyKey = "GUY" -- เปลี่ยน Key ที่คุณต้องการแจกตรงนี้

local GetKeyLink = "https://linkvertise.com/xxxxxx" -- วางลิงก์หา Key ของคุณตรงนี้

local Window = Fluent:CreateWindow({

    Title = "Arsenal VIP 🍋 | Loader",

    SubTitle = "by guyning2553-afk",

    TabWidth = 160,

    Size = UDim2.fromOffset(450, 320),

    Theme = "Dark"

})

local Tabs = {

    Main = Window:AddTab({ Title = "Key System", Icon = "lock" })

}

local KeyInput = ""

Tabs.Main:AddParagraph({

    Title = "Authentication Required",

    Content = "กรุณาใส่ Key เพื่อเข้าใช้งานสคริปต์ Arsenal VIP"

})

Tabs.Main:AddInput("Input", {

    Title = "Enter Key",

    Default = "",

    Placeholder = "วาง Key ที่นี่...",

    Callback = function(Value)

        KeyInput = Value

    end

})

-- ปุ่มตรวจสอบ Key

Tabs.Main:AddButton({

    Title = "Check Key & Load Script",

    Description = "ตรวจสอบและรันสคริปต์หลัก",

    Callback = function()

        if KeyInput == MyKey then

            Fluent:Notify({Title = "Success", Content = "Key ถูกต้อง! กำลังดึงข้อมูลจาก GitHub...", Duration = 3})

            

            -- ปิดหน้าต่างตัวเช็ค Key เพื่อไม่ให้เกะกะ

            Window:Destroy()

            

            -- [[ ส่วนที่ดึงโค้ดของคุณจาก GitHub มาทำงาน ]] --

            local success, err = pcall(function()

                loadstring(game:HttpGet("https://raw.githubusercontent.com/guyning2553-afk/MANOW/refs/heads/main/manao.lua"))()

            end)

            

            if not success then

                warn("เกิดข้อผิดพลาดในการโหลดสคริปต์: " .. tostring(err))

            end

        else

            Fluent:Notify({Title = "Error", Content = "Key ไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง", Duration = 3})

        end

    end

})

-- ปุ่มก๊อปลิงก์หา Key

Tabs.Main:AddButton({

    Title = "Get Key (คัดลอกลิงก์)",

    Callback = function()

        setclipboard(GetKeyLink)

        Fluent:Notify({Title = "System", Content = "คัดลอกลิงก์แล้ว! นำไปวางใน Browser เพื่อหา Key", Duration = 5})

    end

})

Window:SelectTab(1)