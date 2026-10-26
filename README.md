# Создание моделей на dbt

## Витрины

1. ```mart_daily_state_metrics``` — Дневные метрики по штатам

2. ```mart_fraud_by_category``` — Анализ фрода по категориям

3. ```mart_fraud_by_state``` — Географический анализ фрода

4. ```mart_customer_risk_profile``` — Профиль риска клиентов

5. ```mart_hourly_fraud_pattern``` — Временные паттерны фрода

6. ```mart_merchant_analytics``` — Аналитика по мерчантам

## Тестирование
В проекте используются:

1. Стандартные data tests (models/marts/schema.yml и models/staging/schema.yml)

2. Тесты из dbt_utils и dbt_expectations (models/marts/schema.yml)

3. Singular SQL tests (tests/)

4. Unit тесты (models/marts/unit_tests.yml)

## Зависимости
![alt text](src/image.png)

## Дополнительно
Настройка ```sqlfluff``` содержится в .sqlfluff и настройка pre-```commit``` в .pre-commit-config.yaml

## Запуск

- Сборка и запуск тестов: ```make debug```

- Проверка SQL: ```make lint```

- Форматирование SQL: ```make format```

- Полный цикл с документацией: ```make all```