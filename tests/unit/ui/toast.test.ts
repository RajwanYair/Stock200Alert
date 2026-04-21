import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { showToast, clearAllToasts, toastCount } from "../../../src/ui/toast";

describe("toast", () => {
  beforeEach(() => {
    document.body.innerHTML = "";
    clearAllToasts();
  });

  afterEach(() => {
    clearAllToasts();
    document.body.innerHTML = "";
  });

  it("creates a container on first toast", () => {
    expect(document.getElementById("toast-container")).toBeNull();
    showToast({ message: "hello" });
    expect(document.getElementById("toast-container")).not.toBeNull();
  });

  it("shows a toast element in the container", () => {
    showToast({ message: "Test msg" });
    const container = document.getElementById("toast-container")!;
    const toast = container.querySelector(".toast");
    expect(toast).not.toBeNull();
    expect(toast!.textContent).toContain("Test msg");
  });

  it("applies the correct type class", () => {
    showToast({ message: "err", type: "error" });
    const toast = document.querySelector(".toast-error");
    expect(toast).not.toBeNull();
  });

  it("defaults to info type", () => {
    showToast({ message: "info" });
    const toast = document.querySelector(".toast-info");
    expect(toast).not.toBeNull();
  });

  it("tracks active toast count", () => {
    expect(toastCount()).toBe(0);
    showToast({ message: "a", durationMs: 0 });
    showToast({ message: "b", durationMs: 0 });
    expect(toastCount()).toBe(2);
  });

  it("returns a dismiss function", () => {
    const dismiss = showToast({ message: "x", durationMs: 0 });
    expect(toastCount()).toBe(1);
    dismiss();
    expect(toastCount()).toBe(0);
  });

  it("clearAllToasts dismisses all", () => {
    showToast({ message: "a", durationMs: 0 });
    showToast({ message: "b", durationMs: 0 });
    clearAllToasts();
    expect(toastCount()).toBe(0);
  });

  it("has a close button with aria-label", () => {
    showToast({ message: "x" });
    const btn = document.querySelector(".toast-close");
    expect(btn).not.toBeNull();
    expect(btn!.getAttribute("aria-label")).toBe("Dismiss");
  });

  it("container has aria-live polite", () => {
    showToast({ message: "x" });
    const container = document.getElementById("toast-container")!;
    expect(container.getAttribute("aria-live")).toBe("polite");
  });
});
