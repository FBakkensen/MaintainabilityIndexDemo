codeunit 50700 MaintainabilityIndexDemo
{
    procedure ShipItemsToCustomer(CustomerNo: Code[20]; ItemNo: Code[20]; SerialNos: List of [Text])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
        WarehouseShipmentHeader: Record "Warehouse Shipment Header";
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        ArchiveManagement: Codeunit ArchiveManagement;
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
        SerialNo: Text;
    begin
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Modify(true);

        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";

        SalesLine.InitNewLine(SalesLine);
        SalesLine.AddItem(SalesLine, ItemNo);
        SalesLine.Validate(Quantity, SerialNos.Count);
        SalesLine.Modify(true);

        foreach SerialNo in SerialNos do begin
            TempTrackingSpecification.InitFromSalesLine(SalesLine);
            TempTrackingSpecification.Validate("Serial No.", SerialNo);

            CreateReservEntry.CreateReservEntryFrom(TempTrackingSpecification);
        end;

        ArchiveManagement.ArchiveSalesDocument(SalesHeader);
        SalesHeader.PerformManualRelease();
        /*
        GetSourceDocOutbound.CreateFromSalesOrder(SalesHeader);

        WarehouseShipmentLine.SetRange("Source Type", Database::"Sales Line");
        WarehouseShipmentLine.SetRange("Source Subtype", SalesHeader."Document Type".AsInteger());
        WarehouseShipmentLine.SetRange("Source No.", SalesHeader."No.");
        if WarehouseShipmentLine.FindSet() then begin
            WarehouseShipmentHeader.Get(WarehouseShipmentLine."No.");
            repeat
                WarehouseShipmentLine.CreatePickDoc(WarehouseShipmentLine, WarehouseShipmentHeader);
            until WarehouseShipmentLine.Next() = 0;
        end;
        */
    end;
}
