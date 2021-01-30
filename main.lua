local guiLibrary = {}

function guiLibrary.new()
    local gui = {}
    
    local mouse = game:service'Players'.LocalPlayer:GetMouse()
	
	function gui:drag(object)
	    object.MouseEnter:Connect(function()
	        local mouseDown = object.InputBegan:connect(function(key)
				if key.UserInputType == Enum.UserInputType.MouseButton1 then
    				local objectPosition = Vector2.new(mouse.X - object.AbsolutePosition.X, mouse.Y - object.AbsolutePosition.Y);
    				while game:service'RunService'.Heartbeat:wait() and game:service'UserInputService':IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
    					object:TweenPosition(UDim2.new(0, mouse.X - objectPosition.X + (object.Size.X.Offset * object.AnchorPoint.X), 0, mouse.Y - objectPosition.Y + (object.Size.Y.Offset * object.AnchorPoint.Y)), 'Out', 'Quad', 0.1, true);
    				end
    			end
	        end)
	        
		    local leave
		    leave = object.MouseLeave:Connect(function()
		        mouseDown:Disconnect()
		        leave:Disconnect()
	        end)
	    end)
	end
	
	function gui:resizer(p, s)
	    p:GetPropertyChangedSignal('AbsoluteSize'):connect(function()
			s.Size = UDim2.new(s.Size.X.Scale, s.Size.X.Offset, s.Size.Y.Scale, p.AbsoluteSize.Y);
		end)
	end
    
    function gui:create(className, properties)
        local object = Instance.new(className)
        
        if className == "ScreenGui" then
            --syn.protect_gui(object)
        end
        
        for i, v in next, properties do
            if i ~= "Parent" then
                object[i] = v
            end
        end
        
        object.Parent = properties.Parent
        return object
    end
    
    local defaultAppearance = {
		textColour        = Color3.fromRGB(255, 255, 255);
		underlineColour   = Color3.fromRGB(0, 255, 140);
		barColour         = Color3.fromRGB(40, 40, 40);
		backgroundColour  = Color3.fromRGB(30, 30, 30);
		backgroundColour2 = Color3.fromRGB(20, 20, 20);
	}
    
    function gui:newWindow(options)
        local window = {count = 0; toggles = {}; closed = false;}
        options = options or {};
        setmetatable(options, {__index = defaultAppearance})
        setmetatable(window, {__index = self})
        
        gui.screenGui = gui.screenGui or self:create("ScreenGui", {Name = "SynHub"; Parent = game.CoreGui})
        
        window.frame = self:create("Frame", {
            Name = options.text;
            Active = true;
            BackgroundTransparency = 0;
            Size = UDim2.new(0, 500, 0, 30);
            Position = UDim2.new(0.5, 250, 0.5, 0);
            BackgroundColor3 = options.barColour;
            BorderSizePixel = 0;
            AnchorPoint = Vector2.new(1, 0);
            Parent = self.screenGui;
        })
    
        window.underline = self:create("Frame", {
			Name = 'Underline';
			Active = true;
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, -2),
			BorderSizePixel = 0;
			BackgroundColor3 = options.underlineColour;
			Parent = window.frame
		})
    
        window.name = self:create("TextLabel", {
            Active = true;
            BackgroundTransparency = 1;
            Size = UDim2.fromScale(1, 1);
            Text = options.text;
            TextColor3 = Color3.fromRGB(255,255,255);
            Parent = window.frame;
        })
    
        window.background = self:create('Frame', {
			Name = 'Background';
			Active = true;
			Parent = window.frame;
			BorderSizePixel = 0;
			BackgroundColor3 = options.backgroundColour;
			Position = UDim2.new(0, 0, 1, 0);
			Size = UDim2.new(1, 0, 0, 25);
			ClipsDescendants = true;
		})
		
		window.container = self:create('Frame', {
			Name = 'Container';
			Active = true;
			Parent = window.background;
			BorderSizePixel = 0;
			BackgroundColor3 = options.backgroundColour;
			Size = UDim2.new(1, 0, 1, 0);
			ClipsDescendants = true;
		})
		
		window.organizer = self:create('UIListLayout', {
			Name = 'Sorter';
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = window.container;
		})
		
		window.toggle = self:create("TextButton", {
			Name = 'Toggle';
			ZIndex = 10;
			BackgroundTransparency = 1;
			Position = UDim2.new(1, -25, 0, 0);
			Size = UDim2.new(0, 25, 1, 0);
			Text = "-";
			TextSize = 17;
			TextColor3 = options.textColour;
			Font = Enum.Font.SourceSans;
			Parent = window.frame;
		});
	
		window.toggle.MouseButton1Click:connect(function()
			window.closed = not window.closed
			window.toggle.Text = (window.closed and "+" or "-")
			if window.closed then
				window:resize(true, UDim2.new(1, 0, 0, 0))
			else
				window:resize(true)
			end
		end)
		
		function window:nav(tabs, navSettings)
		    if window.navFrame then return end
		    navSettings = navSettings or {}
		    
		    self.navFrame = self:create("Frame", {
		        Name = "Navigation";
		        Active = true;
		        Size = UDim2.new(1, 0, 0, 20);
		        BackgroundColor3 = options.backgroundColour;
		        Parent = self.container;
		    })
		
		    --[[self.underline = self:create("Frame", {
    			Name = 'Underline';
    			Active = true;
    			ZIndex = 2;
    			Size = UDim2.new(1, 0, 0, 2),
    			Position = UDim2.new(0, 0, 1, 0),
    			BorderSizePixel = 0;
    			BackgroundColor3 = options.underlineColour;
    			Parent = self.navFrame
    		})]]
    		
    		self.navFrameContainer = self:create("Frame", {
		        Name = "Container";
		        Active = true;
		        Size = UDim2.new(1, 0, 1, 0);
		        BackgroundColor3 = options.backgroundColour;
		        Parent = self.navFrame;
		    })
    		
    		if options.rainbow then
                --self:rainbow(self.underline, 180)
            end
		
		    self.tabs = {}
		    self.tabs.tabButtons = {}
		    
		    self.tabs.listLayout = self:create("UIListLayout", {
		        FillDirection = "Horizontal";
		        SortOrder = "LayoutOrder";
		        Parent = self.navFrameContainer;
		    })
		    
		    local tabCount = 0
		    for i, v in next, tabs do
		        tabCount = tabCount + 1
		    end
		    for i, v in next, tabs do
		        local tabButton = self:create("TextButton", {
		            Name = i;
		            BackgroundTransparency = 1;
		            Size = UDim2.new(1/tabCount, 0, 1, 0);
		            Text = i;
		            TextColor3 = options.textColour;
		            Font = "Ubuntu";
		            TextSize = 10;
		            Parent = self.navFrameContainer;
		        })
		    
		        tabButton.MouseButton1Click:Connect(function()
		            self.currentTab:TweenPosition(UDim2.new(1, 0, 0, 0), nil, nil, .2)
		            self.tabs[i].Position = UDim2.new(-1, 0, 0, 0)
		            self.tabs[i]:TweenPosition(UDim2.new(0, 0, 0, 0), nil, nil, .2)
		            self.currentTab = self.tabs[i]
		        end)
		        
		        table.insert(self.tabs.tabButtons, tabButton)
		    end
		    
		    self:resize()
		    return window.navFrame
		end
		
		function window:addSection(sectionOptions)
		    assert(sectionOptions, "Must include arguments to function")
		    
		    if not self.sectionContainer then
		        self.sectionContainer = self:create("Frame", {
		            Name = "SectionContainer";
		            BackgroundTransparency = 1;
		            Size = UDim2.new(1, 0, 0, 150);
		            Parent = self.container;
		        })
		    end
		    
		    self.count = self.count + 1
		    local section = {}
		    setmetatable(section, {__index = self})
		    section.scrollingFrame = self:create("ScrollingFrame", {
		        Name = sectionOptions.name;
		        Active = true;
		        BackgroundColor3 = options.backgroundColour2;
		        BorderSizePixel = 0;
		        Size = UDim2.new(1, 0, 0, 150);
		        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
		        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
		        Parent = self.sectionContainer;
		    })
		
		    self:create("UIListLayout", {
		        SortOrder = "LayoutOrder";
		        Parent = section.scrollingFrame;
		    })
		    
    		function section:addFrame(frameOptions)
    		    if not self.frames then self.frames = {} end
    		    assert(type(frameOptions) == "table", "Must supply frame options: {size = 0; frameType = 'Label';}")
    		    self.count = self.count + 1
    		    
    		    local frame = {}
    		    setmetatable(frame, {__index = self})
    		    
    		    frame.frame = self:create("Frame", {
    		        Size = UDim2.new(1, 0, 0, frameOptions.size);
    		        BackgroundColor3 = options.backgroundColour2;
    		        BorderSizePixel = 0;
    		        Parent = self.scrollingFrame;
    		    })
    		
    		    if frameOptions.frameType == "Label" then
    		        self:create("TextLabel", {
    		            Size = UDim2.new(1, 0, 1, 0);
    		            Text = frameOptions.text;
    		            TextColor3 = options.textColour;
    		            BackgroundTransparency = 1;
    		            TextSize = 16;
    		            Font = "Ubuntu";
    		            BorderSizePixel = 0;
    		            Parent = frame.frame;
    		        })
    		    elseif frameOptions.frameType == "Button" then
    		        local button = self:create("TextButton", {
    		            AnchorPoint = Vector2.new(0.5, 0.5);
    		            Size = UDim2.new(0.375, 0, 0.8, 0);
    		            Position = UDim2.new(0.5, 0, 0.5, 0);
    		            Text = frameOptions.text;
    		            TextColor3 = options.textColour;
    		            BackgroundTransparency = 0;
    		            BackgroundColor3 = options.backgroundColour;
    		            TextSize = 16;
    		            Font = "Ubuntu";
    		            BorderSizePixel = 0;
    		            Parent = frame.frame;
    		        })
    		        button.MouseButton1Click:Connect(function()
    		            frameOptions.onClicked(button)
    		        end)
    		    end
    		
    		    local ySum = 0
    		    for i, v in next, self.scrollingFrame:GetChildren() do
    		        pcall(function()
    		            ySum = ySum + v.AbsoluteSize.Y
    		        end)
    		    end
    		    self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ySum)
    		
    		    return frame
    		end
    		
    		self:resize()
    		if not self.currentTab then
		        self.currentTab = section.scrollingFrame
		    end
    		self.tabs[sectionOptions.name] = section.scrollingFrame
    		return section
    	end
		
		function window:getSize()
			local ySize = 0;
			for i, object in next, self.container:GetChildren() do
				if (not object:IsA('UIListLayout')) and (not object:IsA('UIPadding')) then
					ySize = ySize + object.AbsoluteSize.Y
				end
			end
			return UDim2.new(1, 0, 0, ySize)
		end
	
		function window:resize(tween, change)
			local size = change or self:getSize()
			
			if tween and not tweening then
			    tweening = true
			    if self.closed then
			        self.background:TweenSize(size, "Out", "Sine", 0.2, true)
			        wait(.2)
			        self.frame:TweenSize(UDim2.new(0, 100, 0, 30), "Out", "Sine", 0.2, true)
				else
				    self.frame:TweenSize(UDim2.new(0, 500, 0, 30), "Out", "Sine", 0.2, true)
				    wait(.2)
				    self.background:TweenSize(size, "Out", "Sine", 0.2, true)
			    end
			    tweening = false
			else
				self.background.Size = size
			end
		end
		
		function window:rainbow(object, rotation)
    		coroutine.resume(coroutine.create(function()
    		    if not rotation then rotation = 0 end
    		    local counter1, counter2 = 0, 0.5
    		    local gradient = Instance.new("UIGradient")
    		        gradient.Rotation = rotation
    		        gradient.Parent = object
    		    while wait() do
    		        gradient.Color = ColorSequence.new({
    		            ColorSequenceKeypoint.new(0, Color3.fromHSV(math.acos(math.cos(counter1*math.pi))/math.pi,1,1)),
    		            ColorSequenceKeypoint.new(1, Color3.fromHSV(math.acos(math.cos(counter2*math.pi))/math.pi,1,1))
    		        })
    		        counter1 = counter1 + 0.025; counter2 = counter2 + 0.025;
    		    end
    		end))
    	end
    
        self:drag(window.frame)
        self:resizer(window.container, window.background)
        
        if options.rainbow then
            window:rainbow(window.underline)
        end
        
        return window
    end

    return gui
end

return guiLibrary.new()
