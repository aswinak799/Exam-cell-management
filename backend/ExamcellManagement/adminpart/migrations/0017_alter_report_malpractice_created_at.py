# Generated by Django 4.1.7 on 2023-03-25 06:05

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('adminpart', '0016_report_malpractice_alloc_id_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='report_malpractice',
            name='created_at',
            field=models.DateTimeField(auto_now_add=True),
        ),
    ]