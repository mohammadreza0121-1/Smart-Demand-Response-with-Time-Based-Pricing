% پارامترهای سیستم
mass = 15; % Kg
inertia = 5; % Kgm^2
half_distance = 0.15; % m
wheel_radius = 0.05; % m
cog_distance = 0.1; % m

% تعریف m_d
m_d = mass * cog_distance;

% زمان شبیه‌سازی
simulation_duration = 10; % زمان شبیه‌سازی به ثانیه
time_step = 0.1; % گام زمانی
time_vector = 0:time_step:simulation_duration;
num_samples = length(time_vector);

% مقدار اولیه وضعیت و سرعت
initial_position = [0; 0; 0]; % مقدار اولیه وضعیت
initial_velocity = [0; 0; 0]; % مقدار اولیه سرعت

% مسیر مرجع (مسیر مربعی)
square_side = 1; % طول یک ضلع مربع
segment_samples = floor(num_samples / 4);

x_ref = [linspace(0, square_side, segment_samples), ...
         square_side * ones(1, segment_samples), ...
         linspace(square_side, 0, segment_samples), ...
         zeros(1, segment_samples)];

y_ref = [zeros(1, segment_samples), ...
         linspace(0, square_side, segment_samples), ...
         square_side * ones(1, segment_samples), ...
         linspace(square_side, 0, segment_samples)];

theta_ref = [zeros(1, segment_samples), ...
             (pi/2) * ones(1, segment_samples), ...
             pi * ones(1, segment_samples), ...
             (3*pi/2) * ones(1, segment_samples)];

% اطمینان از هماهنگی طول بردارهای مرجع با بردار زمان
if length(x_ref) < num_samples
    x_ref = [x_ref, x_ref(end) * ones(1, num_samples - length(x_ref))];
    y_ref = [y_ref, y_ref(end) * ones(1, num_samples - length(y_ref))];
    theta_ref = [theta_ref, theta_ref(end) * ones(1, num_samples - length(theta_ref))];
elseif length(x_ref) > num_samples
    x_ref = x_ref(1:num_samples);
    y_ref = y_ref(1:num_samples);
    theta_ref = theta_ref(1:num_samples);
end

% مقداردهی اولیه مسیر ربات
x_pos = zeros(1, length(time_vector));
y_pos = zeros(1, length(time_vector));
orientation = zeros(1, length(time_vector));

% مقداردهی اولیه سرعت‌ها
linear_velocity_history = zeros(1, length(time_vector));
angular_velocity_history = zeros(1, length(time_vector));

% مقداردهی اولیه خطاها
x_error = zeros(1, length(time_vector));
y_error = zeros(1, length(time_vector));
theta_error = zeros(1, length(time_vector));

% سرعت‌های اولیه
linear_velocity = 0.5; % سرعت اولیه خطی
angular_velocity = 0.1; % سرعت اولیه زاویه‌ای

% مقداردهی اولیه شبکه عصبی RBF
hidden_neurons = 15; % تعداد نورون‌ها در لایه مخفی RBF
centers = randn(3, hidden_neurons); % مراکز توابع گوسی (3 ورودی، M نورون)
widths = randn(hidden_neurons, 1); % عرض (پخش) توابع گوسی
weights = randn(hidden_neurons, 1); % وزن‌های سیناپسی برای خروجی شبکه

% نرخ یادگیری
learn_rate = 0.05;

% حلقه کنترلی
for k = 2:length(time_vector)
    % محاسبه خطاها
    x_error(k) = x_ref(k) - x_pos(k-1);
    y_error(k) = y_ref(k) - y_pos(k-1);
    theta_error(k) = theta_ref(k) - orientation(k-1);
    
    % به‌روزرسانی سرعت‌های خطی و زاویه‌ای
    linear_velocity = 0.5 * sqrt(x_error(k)^2 + y_error(k)^2);
    angular_velocity = 0.5 * theta_error(k);
    
    % ذخیره سرعت‌ها برای رسم نمودار
    linear_velocity_history(k) = linear_velocity;
    angular_velocity_history(k) = angular_velocity;
    
    % به‌روزرسانی موقعیت ربات
    x_pos(k) = x_pos(k-1) + linear_velocity * cos(orientation(k-1)) * time_step;
    y_pos(k) = y_pos(k-1) + linear_velocity * sin(orientation(k-1)) * time_step;
    orientation(k) = orientation(k-1) + angular_velocity * time_step;
    
    % به‌روزرسانی ماتریس‌ها و بردارهای دینامیکی
    M_matrix = [mass 0 m_d * sin(orientation(k)); 0 mass -m_d * cos(orientation(k)); m_d * sin(orientation(k)) -m_d * cos(orientation(k)) inertia];
    V_matrix = [0 0 m_d * angular_velocity * cos(orientation(k)); 0 0 m_d * angular_velocity * sin(orientation(k)); 0 0 0];
    G_vector = [0; 0; 0];
    B_matrix = (1/wheel_radius) * [cos(orientation(k)) cos(orientation(k)); sin(orientation(k)) sin(orientation(k)); half_distance -half_distance];
    A_matrix = [-sin(orientation(k)) cos(orientation(k)) -cog_distance]; % ماتریس مرتبط با قیود ربات
    lambda_val = -mass * (x_pos(k) * cos(orientation(k)) + y_pos(k) * sin(orientation(k))) * angular_velocity; % بردار نیروهای مقید
    
    % کنترل‌کننده عصبی (RBF)
    % محاسبه فعال‌سازی‌های RBF
    activations = zeros(hidden_neurons, 1);
    input_vec = [x_pos(k); y_pos(k); orientation(k)]; % ورودی مثال
    for j = 1:hidden_neurons
        activations(j) = exp(-norm(input_vec - centers(:, j))^2 / (2 * widths(j)^2));
    end
    
    % محاسبه خروجی شبکه عصبی RBF
    control_signal = activations' * weights; % خروجی کنترل مثال
    
    % به‌روزرسانی ورودی‌های کنترلی بر اساس خروجی شبکه عصبی
    torques = control_signal; % به‌روزرسانی مثال

    % به‌روزرسانی وزن‌های شبکه عصبی
    weights = weights + learn_rate * (x_error(k) + y_error(k) + theta_error(k)) * activations;
end

% رسم نتایج
figure;
plot(x_ref, y_ref, 'r--', 'LineWidth', 2); hold on;
plot(x_pos, y_pos, 'b-', 'LineWidth', 2);
xlabel('X Position');
ylabel('Y Position');
legend('Reference Trajectory', 'Robot Trajectory');
title('Robot Trajectory vs Reference Trajectory');
grid on;

figure;
plot(time_vector, x_error, 'r', 'LineWidth', 2); hold on;
plot(time_vector, y_error, 'b', 'LineWidth', 2);
plot(time_vector, theta_error, 'g', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Error');
legend('Error in X', 'Error in Y', 'Error in \theta');
title('Error between Robot Trajectory and Reference Trajectory');
grid on;

figure;
subplot(2,1,1);
plot(time_vector, linear_velocity_history, 'b', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Linear Velocity (v)');
title('Linear Velocity over Time');
grid on;

subplot(2,1,2);
plot(time_vector, angular_velocity_history, 'r', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Angular Velocity (\omega)');
title('Angular Velocity over Time');
grid on;
